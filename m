Content-Type: multipart/mixed; boundary="===============4238734834694233876=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 1/3] buf: Add a generic extensible buffer struct
Date: Tue, 12 Jan 2021 17:00:21 -0800
Message-ID: <a78e8f12-d5f2-5aec-18f-a43a5fd6ea81@linux.intel.com>
In-Reply-To: <20210108011324.1551320-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4238734834694233876==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 8 Jan 2021, Andrew Zaborowski wrote:

> Add a generic buffer class that can extend to the left and to the right
> as data is appended or prepended.  Nested buffers can also be added.
> Building the complicated structures of nested genl attributes and also
> various structures like 802.11 IEs passed in the contents of those
> attributes is the motivation for this.
>
> l_buf_new() and l_buf_append_new() take the amount of buffer space and
> the number of nested buffers to pre-allocate but the user can go over
> these values and the buffers will grow.  While the code looks a little
> complicated most operations are actually simple when the buffers don't
> need to grow.
>
> I considered these few features, all of which would be nice to have
> for l_genl_msg building for example, but, some of which are mutually
> exclusive without blowing up the size of struct l_buf, the complexity
> or the number of mallocs:
>
> 1. nested l_bufs can be added *at the head*, in addition to at the
>   tail, of the parent l_buf.  (similar to how static data can be
>   prepended or appended to the current l_buf)
>
> 2. multiple nested buffers of one parent can exist at the same time
>   and be written into or have their own children added in random
>   order.
>
> 3. l_buf contains enough information to detect when the initial
>   @nested_cnt iovecs are exhausted, in l_buf_append_new().
>
> 4. on top of 3. the iov array automatically extends when the initial
>   @nested_cnt iovecs are exhausted, in l_buf_append_new(), rather
>   than return NULL.
>   When the iov array extends parent/children nested l_bufs don't
>   become invalid.
>
> 5. no extra "finalize" call is required after all data is written
>   to all nested buffers and no tree structure needs to be flattened,
>   the iov array is ready to use in a writev() at any time.
>
> 6. on top of 5. no l_buf_free() is needed for nested buffers.
>   The number of l_buf_free calls matches the number of l_buf_new
>   calls only.
>
> This version sacrifices 1. and 2. for 3., 4., 5. and 6.
> ---
> Makefile.am |   6 +-
> ell/buf.c   | 192 ++++++++++++++++++++++++++++++++++++++
> ell/buf.h   | 258 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> ell/ell.h   |   1 +
> ell/ell.sym |   5 +
> 5 files changed, 460 insertions(+), 2 deletions(-)
> create mode 100644 ell/buf.c
> create mode 100644 ell/buf.h
>

...

> diff --git a/ell/buf.h b/ell/buf.h
> new file mode 100644
> index 0000000..a3d64d3
> --- /dev/null
> +++ b/ell/buf.h
> @@ -0,0 +1,258 @@
> +/*
> + *
> + *  Embedded Linux library
> + *
> + *  Copyright (C) 2021  Intel Corporation. All rights reserved.
> + *
> + *  This library is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU Lesser General Public
> + *  License as published by the Free Software Foundation; either
> + *  version 2.1 of the License, or (at your option) any later version.
> + *
> + *  This library is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + *  Lesser General Public License for more details.
> + *
> + *  You should have received a copy of the GNU Lesser General Public
> + *  License along with this library; if not, write to the Free Software
> + *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-130=
1  USA
> + *
> + */
> +
> +#ifndef __ELL_BUF_H
> +#define __ELL_BUF_H
> +
> +#include <sys/uio.h>
> +#include <stdint.h>
> +#include <stddef.h>
> +
> +#ifdef __cplusplus
> +extern "C" {
> +#endif
> +
> +/*
> + * At the low level this stores up to @alloced_cnt contiguous buffers or
> + * segments.  Within each segment there's a "used" part of the segment
> + * identified by the start pointer and the length.  There's also
> + * differentation between base l_bufs, that own the allocated memory,
> + * and nested l_bufs that point to their parent l_buf's segments.
> + *
> + * In the base l_buf, the @iovecs array contains 2 * @alloced_cnt iovecs.
> + * The last @alloced_cnt iovecs each point at the entirety of the
> + * corresponding segment's allocated memory while the first @alloced_cnt
> + * iovecs point at the "used" part of the corresponding segment.  Only
> + * segments from 0 to (@used_cnt - 1) have memory allocated.
> + *
> + * @used[0] is the "used" iovec for the "current" segment, i.e. anything
> + * between @used->iov_base and @used->iov_base + @used->iov_len.
> + * @used + @alloced_cnt points at the entirety of the "current" segment.
> + * Anything before @used->iov_base (and after @used[alloced_cnt].iov_bas=
e)
> + * is the headroom and anything after @used->iov_base + @used->iov_len
> + * (up to @used[alloced_cnt].iov_base + @used[alloced_cnt].iov_len) is
> + * the tailroom.  Initally the "used" part is empty, i.e. @used->iov_base
> + * points somewhere inside the allocated segment and @used->iov_len is 0.
> + * l_buf_prepend() is then used to expand it into the headroom and
> + * l_buf_append() to expand it into the tailroom, reducing the available
> + * room.  The headroom and tailroom of the allocated segments, and the
> + * @iov_base and @iov_len of the not-yet-allocated segments have
> + * uninitialized values.
> + *
> + * There's no way to change which segment is "current".  The segments
> + * after "current" are accessed by creating a nested l_buf using
> + * l_buf_append_init() and l_buf_append_new().  Its "current" segment is
> + * going to be different.  Segments are allocated their memory when they
> + * become the "current" segment of an l_buf.  That memory is not freed
> + * until the base l_buf is freed though.  Nested l_bufs can't be freed
> + * using l_buf_free, they're also automatically freed with the base l_bu=
f.
> + * A nested l_buf and all its childred l_bufs also become invalid when
> + * a new call to l_buf_append_new() is made for the same parent l_buf or
> + * its ancestor.
> + */
> +struct l_buf {
> +	struct {
> +		struct l_buf *parent;
> +		struct l_buf *child;
> +		struct iovec *used;
> +		unsigned int alloced_cnt;
> +	};
> +	unsigned int used_cnt;
> +	struct iovec iovecs[0];
> +};

Hi Andrew,

I was expecting to see an opaque structure for l_buf here in the header - =

that seems more typical for ELL!

Looking at patch #2 in the series, the genl code is mainly accessing =

buf->used and buf->used_cnt. My recommendation to make the API fit in ELL =

better, and to clarify the API, would be to make struct l_buf opaque and =

add some accessors that just return buf->used and buf->used_cnt - maybe =

l_buf_get_iov_base() and l_buf_get_iov_cnt()?

Alternately, if some of the inline functions in buf.h that access the =

struct members really need to be inline, the structure could remain =

exposed. I lean toward moving a bunch of that inline code to buf.c though.

Unit tests for l_buf would be good too.


Thanks!


--
Mat Martineau
Intel
--===============4238734834694233876==--

