Content-Type: multipart/mixed; boundary="===============3381213311309552093=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v5 1/5] tls: Check buffer bounds in tls_rsa_sign
Date: Mon, 20 Jun 2016 12:15:56 -0500
Message-ID: <576824CC.5040602@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1606200939460.4967@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3381213311309552093==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

 >>
>>> +        len -=3D 2;
>>
>> This doesn't seem right.  By my reading the total bytes being written
>> here are key_size (in cipher_sign) and 2 bytes just above.
>
> This is accounting for the two bytes written to 'out' above, which
> happens in that block of the 'if' statement but not the 'else' block.
>

Ah yes, you're right.  We write key_size + 4 bytes in case of TLS 1.2.

>>
>> Why are you checking for len >=3D key_size + 2 below?
>
> The key_size bytes written by cipher_sign and the 2 bytes written by
> le_put_be16.

Yep, my bad.

Regards,
-Denis

--===============3381213311309552093==--

