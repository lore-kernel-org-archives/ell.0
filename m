Content-Type: multipart/mixed; boundary="===============1354739271225956668=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 07/10] cipher: Add l_cipher_from_pkcs5_id
Date: Fri, 11 Aug 2017 19:30:39 -0500
Message-ID: <33cf2bba-84ec-5624-f59b-521ca5694f5f@gmail.com>
In-Reply-To: <CAOq732+HP0MSRPUAibeEbdKJBuGFBXdb5OPgku6NjZxJQ5zTLA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1354739271225956668==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

>> Another reason to move this is that I don't really want to expose it in
>> l_cipher.  The right way for us to enable encrypted certificates is via =
the
>> keyctl API.  Until then, we should stuff this into some private file.  C=
an
>> we put this into asn1-private.[ch]?
> =

> If we're going to have pkcs5.c, perhaps let's put it there since all
> of this is basically PKCS#5?  We would then also need pkcs5-private.h,
> is that too many files?
> =


I'm not to worried about the number of files.  I am mostly worried about =

introducing something into the public API and then taking it out later. =

So if we want iwd to use whatever is inside pkcs5.[ch], then it probably =

should be public/exported API, which means it isn't a good candidate for =

l_cipher_from_pkcs5_id either.  That one should be private and hence I =

was thinking of having it in asn1-private.  If you think it belongs =

logically with pkcs5, then we could introduce pkcs5-private.h =

specifically for that purpose.

Hope that made sense.

Regards,
-Denis

--===============1354739271225956668==--

