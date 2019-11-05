Content-Type: multipart/mixed; boundary="===============8711329349619588189=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ELL double free during debug exit cleanup
Date: Tue, 05 Nov 2019 14:48:48 -0600
Message-ID: <5d1bbc5b-dea9-4efd-be73-fda983b3edca@gmail.com>
In-Reply-To: <25e80daf8ab246354710b61534ffe3a8bd4945c6.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8711329349619588189==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

>> -__attribute__((constructor)) static void register_debug_section()
>> +__attribute__((constructor)) void l_register_debug_section()

So really, this would be about the last solution I'd pick, no matter =

where the forward declaration lives.

Have you looked into why the library/or this file is being statically =

linked twice?

Regards,
-Denis
--===============8711329349619588189==--

