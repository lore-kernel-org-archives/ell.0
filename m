Content-Type: multipart/mixed; boundary="===============3208044092388976349=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: ELL API changes before stabilizing
Date: Fri, 07 Oct 2016 11:05:33 -0700
Message-ID: <alpine.OSX.2.20.1610070936570.45755@mjmartin-mac01.local>
In-Reply-To: <57F69D29.3000906@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3208044092388976349==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Thu, 6 Oct 2016, Denis Kenzior wrote:

> Hi Mat,
>
>>
>> My whole point here is that I see it as a favorable tradeoff to pass an
>> extra '0' to the timeout APIs when subsecond resolution is not required
>> rather than have superfluous API calls. It's only a matter of what ELL
>> users see in their code, not code efficiency: the current whole-second
>> APIs are just wrappers around full-resolution common code anyway. If the
>> whole-seconds use case is overly impacted by the extra parameter, then
>> the tradeoff may not be favorable.
>
> That is really what I meant.  I want to save the users from typing the ex=
tra =

> 0 parameter unnecessarily.  We already have 4 arguments to l_timeout_crea=
te, =

> with lots of potential zeros.

Ok, sounds fine.

>> I agree that nanoseconds are overkill, but I don't mind seeing the
>> platform detail filter up to the ELL API level. In practice,
>> milliseconds are likely sufficient and would save a lot of '0' keypresse=
s.
>> =

>
> Hence my question.  Do we actually need to expose nanoseconds?  I can't =

> believe someone needs that level of precision.  MS is fine.

Sounds like we're in agreement that nanoseconds are overkill and ms is =

sufficient.

> If we add the range stuff in, then that's another argument or two, depend=
ing =

> on representation.
>
> I actually don't mind multiple constructors. They're just shorthands and =
are =

> easier to read than trying to parse the arguments.  We can include a rang=
e =

> fudge factor as part of the API.  e.g. second version of timeout_create =

> fudges by +/- 500ms.  MS versions can fudge by +/- 500 nanoseconds, etc.
>
> And if someone wants full control, then a full-blown provide-everything =

> constructor can be added.

Works for me. Do we have a consensus around removing the nanosecond =

versions and adding:

struct l_timeout *l_timeout_create_ms(unsigned long milliseconds,
 					l_timeout_notify_cb_t callback,
                         		void *user_data,
 					l_timeout_destroy_cb_t destroy);
void l_timeout_modify_ms(struct l_timeout *timeout,
                                 unsigned long milliseconds);


--
Mat Martineau
Intel OTC

--===============3208044092388976349==--

