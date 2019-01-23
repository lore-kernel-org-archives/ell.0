Content-Type: multipart/mixed; boundary="===============5953346539282214423=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/2] key: Avoid using C++ keywords as param names.
Date: Wed, 23 Jan 2019 13:50:39 -0600
Message-ID: <233b38a4-2c61-5bef-2253-c912f10cdfa3@gmail.com>
In-Reply-To: <20190123192422.12623-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5953346539282214423==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 01/23/2019 01:24 PM, Ossama Othman wrote:
> Rename the parameter names "public" and "private" to avoid conflicts
> with the similarly named C++ keywords.  Addresses compile-time errors
> in C++ code that includes <ell/key.h>.
> ---
>   ell/key.h | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
> =


Applied, thanks.

I let Marcel figure out what to do with the second patch since it =

touches the build system.

Regards,
-Denis


--===============5953346539282214423==--

