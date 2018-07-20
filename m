Content-Type: multipart/mixed; boundary="===============8292377782611058209=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] fswatch: Add fswatch API
Date: Fri, 20 Jul 2018 13:57:17 -0500
Message-ID: <66e4f020-0cb4-c93c-27cc-44ed90c0eeb7@gmail.com>
In-Reply-To: <20180720181249.21876-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8292377782611058209==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 07/20/2018 01:12 PM, Andrew Zaborowski wrote:
> Add the header and the implementation for a filesystem watch API.  It's
> a simple wrapper around the Linux inotify mechanism but not named inotify
> so as not to preclude using other mechanisms in the implementation.
> ---
>   Makefile.am   |   6 +-
>   ell/ell.h     |   1 +
>   ell/fswatch.c | 255 +++++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/fswatch.h |  44 ++++++++++
>   4 files changed, 304 insertions(+), 2 deletions(-)
>   create mode 100644 ell/fswatch.c
>   create mode 100644 ell/fswatch.h
> =


Both applied, thanks.

Regards,
-Denis


--===============8292377782611058209==--

