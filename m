Content-Type: multipart/mixed; boundary="===============4061479536602682544=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 07/11] gvariant: Utility to build GVariant message out
 of header+body
Date: Tue, 12 Apr 2016 16:44:58 -0500
Message-ID: <570D6C5A.9080502@gmail.com>
In-Reply-To: <1460426175-25501-7-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4061479536602682544==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

 > +	out_buf[pos++] =3D 0;
> +	out_buf[pos++] =3D '(';
> +	memcpy(out_buf + pos, signature, strlen(signature));
> +	pos +=3D strlen(signature);
> +	out_buf[pos++] =3D ')';

Is this written down anywhere?  Why is the body enclosed in a structure?

Do we handle this structure in the parsing phase somewhere?  Can't seem =

to locate that.

> +	write_word_le(out_buf + pos, header_end, offset_size);
> +}
>

Regards,
-Denis

--===============4061479536602682544==--

