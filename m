Content-Type: multipart/mixed; boundary="===============5340956239231552034=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] dbus: Fix subpath comparisons in object tree walk
Date: Thu, 16 Aug 2018 11:25:02 -0500
Message-ID: <f6cdfb89-a8f6-1ca6-11ec-1360eeb19cdb@gmail.com>
In-Reply-To: <20180816020432.11506-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5340956239231552034==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/15/2018 09:04 PM, Andrew Zaborowski wrote:
> By only using strncmp(child->subpath, path, len) we'd only check that
> child->subpath had path as its prefix in makepath_recurse.  As a
> result, if an object at /ab was added first and at /a second, the
> second object would not get a new node created and strangely none of
> our tests or users have caught this.
> ---
>   ell/dbus-service.c | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
> =


All applied, thanks.

Regards,
-Denis


--===============5340956239231552034==--

