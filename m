Content-Type: multipart/mixed; boundary="===============1188714213434356956=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/5] key: Make key/keychain revocation optional when
 freeing
Date: Mon, 24 Oct 2016 15:45:28 -0500
Message-ID: <580E72E8.9080303@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1610241325170.1909@mjmartin-mac01.wa.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1188714213434356956==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

 >> +1.  Although we do have precedent for this in l_string_free, but that
>> is mostly how GLib API was done.
>
> Ok, I'll go with l_key_revoke_and_free(). It was l_string_free that sent
> me in the original add-a-flag direction, but that's also a function that
> has been a source of confusion.
>

Yeah, blame GLib for that.  The point of ell was to make it easy to port =

GLib based projects, so I'm not sure if changing l_string_free is better =

or worse.

I would personally vote for l_key_free and l_key_free_norevoke.

Regards,
-Denis

--===============1188714213434356956==--

