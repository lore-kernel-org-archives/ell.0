Content-Type: multipart/mixed; boundary="===============1963791856904519811=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ELL unit test problem with Link Time Optimization, l_getrandom,
 test-ecdh
Date: Wed, 06 Nov 2019 11:58:07 -0600
Message-ID: <d826a57f-ec8f-fd58-4119-7bbe8f4c93ce@gmail.com>
In-Reply-To: <c5629468613b76d7fe650006c2276f7f49a42e2b.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1963791856904519811==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

On 11/6/19 10:50 AM, Gix, Brian wrote:
> While examining my BlueZ issues with building with LTO, I came accross
> the following issue in the ELL unit test of ECDH:

https://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D88643

May I suggest that the distro in question figures this out by =

themselves, there's nothing wrong in ell.

If they insist on using LTO, then at least disable it for that test.

Regards,
-Denis
--===============1963791856904519811==--

