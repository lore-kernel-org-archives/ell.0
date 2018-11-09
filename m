Content-Type: multipart/mixed; boundary="===============7283858505429302801=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] key: Have kernel handle padding
Date: Thu, 08 Nov 2018 18:55:43 -0600
Message-ID: <54aecedf-288b-6c69-1288-9a73ee757b37@gmail.com>
In-Reply-To: <alpine.OSX.2.21.1811081347530.6619@dbdavenp-mobl.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7283858505429302801==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 11/08/2018 04:07 PM, Mat Martineau wrote:
> Hi Denis,
> =

> On Thu, 8 Nov 2018, Denis Kenzior wrote:
> =

> Worth having the commit message note the kernel version where the =

> padding functionality returns?
> =


Right, I'll mention that.

> =

> You can drop random.h from the includes now.
> =


Done.

>> =C2=A0=C2=A0=C2=A0=C2=A0ret_len =3D eds_common(key, cipher, checksum, pa=
dded ?: in, out,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 padded ? len_out : len_in, len_out,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 KEYCTL_PKEY_ENCRYPT);
> =

> The 'padded' variable needs to be removed from this function too.

Yep, done.

I also took out the L_CHECKSUM_NONE checks.

> =

> Otherwise, looks good. (I haven't run this with a 4.20 rc build though)
> =

> =


I'm running linux-security on my test box and unit tests check out in =

valgrind.

Regards,
-Denis

--===============7283858505429302801==--

