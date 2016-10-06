Content-Type: multipart/mixed; boundary="===============6578263807286813001=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ELL API changes before stabilizing
Date: Thu, 06 Oct 2016 13:51:21 -0500
Message-ID: <57F69D29.3000906@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1610061013210.28728@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6578263807286813001==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

 >
> My whole point here is that I see it as a favorable tradeoff to pass an
> extra '0' to the timeout APIs when subsecond resolution is not required
> rather than have superfluous API calls. It's only a matter of what ELL
> users see in their code, not code efficiency: the current whole-second
> APIs are just wrappers around full-resolution common code anyway. If the
> whole-seconds use case is overly impacted by the extra parameter, then
> the tradeoff may not be favorable.

That is really what I meant.  I want to save the users from typing the =

extra 0 parameter unnecessarily.  We already have 4 arguments to =

l_timeout_create, with lots of potential zeros.

> I agree that nanoseconds are overkill, but I don't mind seeing the
> platform detail filter up to the ELL API level. In practice,
> milliseconds are likely sufficient and would save a lot of '0' keypresses.
>

Hence my question.  Do we actually need to expose nanoseconds?  I can't =

believe someone needs that level of precision.  MS is fine.

If we add the range stuff in, then that's another argument or two, =

depending on representation.

I actually don't mind multiple constructors. They're just shorthands and =

are easier to read than trying to parse the arguments.  We can include a =

range fudge factor as part of the API.  e.g. second version of =

timeout_create fudges by +/- 500ms.  MS versions can fudge by +/- 500 =

nanoseconds, etc.

And if someone wants full control, then a full-blown provide-everything =

constructor can be added.

Regards,
-Denis


--===============6578263807286813001==--

