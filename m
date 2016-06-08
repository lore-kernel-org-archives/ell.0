Content-Type: multipart/mixed; boundary="===============1870209626226317842=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] main: Manually initialize and clean up the main loop
Date: Wed, 08 Jun 2016 13:31:36 -0500
Message-ID: <57586488.4010005@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1606081023230.16651@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1870209626226317842==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

 >>
>> Can you do me a favor and split these into three patches, according to
>> HACKING 'Submitting Patches'.
>
> What do you know, "patches should be split even if breaking compilation
> is unavoidable". Curious about why this is (I'm not lobbying for a
> change, it's just not self-evident).
>

We hardly ever use git bisect, so readability of commits trumps the =

breaking of compilation.

>>
>> I wonder if returning bool here is useful since you never check the
>> return value in any of the actual files that use this.
>
> All of the unit tests and examples exit out of main immediately after
> calling l_main_exit, but that may not be the case for every program.
> l_main_exit will do nothing if the main loop is still running.
>
> l_main_run and l_main_quit's return values are similarly ignored, but
> are potentially useful in a similar way.
>

Fair enough, just curious.  Some like to use void *_exit functions =

because you can't do anything if stuff fails anyway.  I've had this =

argument with myself many times and don't really have a preference.

Regards,
-Denis

--===============1870209626226317842==--

