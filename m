Content-Type: multipart/mixed; boundary="===============4323777346751110189=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] uintset: Add l_uintset_intersect
Date: Thu, 07 Mar 2019 10:11:15 -0600
Message-ID: <2032cfd5-bb20-273d-6cda-d3b34eacad99@gmail.com>
In-Reply-To: <20190307001707.22395-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4323777346751110189==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 03/06/2019 06:17 PM, Tim Kourt wrote:
> l_uintset_intersect computes the intersection of two sets
> of an equal base.
> ---
>   ell/uintset.c | 37 +++++++++++++++++++++++++++++++++++++
>   ell/uintset.h |  3 +++
>   2 files changed, 40 insertions(+)
> =


Applied.  But note that since you're adding a new public API, you should =

also add an entry to ell/ell.sym.  This is a necessary manual step at =

the moment until Marcel fixes the build system to do this properly.

Anyhow, I fixed this for you in a follow-on commit.

Regards,
-Denis


--===============4323777346751110189==--

