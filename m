Content-Type: multipart/mixed; boundary="===============9173511745394474699=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] settings: Overwrite values before freeing memory
Date: Mon, 30 Apr 2018 11:04:58 -0500
Message-ID: <dc0c5cfe-0ae2-3f24-ad66-4a09d7d6fe2c@gmail.com>
In-Reply-To: <alpine.OSX.2.21.1804300840341.4562@seskerx-mobl.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9173511745394474699==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

>> =C2=A0=C2=A0=C2=A0=C2=A0l_free(pair->key);
>> +=C2=A0=C2=A0=C2=A0 memset(pair->value, 0, strlen(pair->value));
> =

> l_free can handle pair->value =3D=3D NULL, but strlen and memset can't. I=
s =

> it worth checking for that?
> =


pair->value is always validated to be not NULL, so strictly speaking =

this isn't necessary.  We could opt to be paranoid of course...

Regards,
-Denis

--===============9173511745394474699==--

