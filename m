Content-Type: multipart/mixed; boundary="===============3184682964804455473=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/5] Support C89 ELL builds
Date: Tue, 05 Mar 2019 14:10:24 -0600
Message-ID: <51064e66-d441-ed43-7bfe-68c0c90a162c@gmail.com>
In-Reply-To: <20190305185618.bussn7oezahr6gbo@kynes>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3184682964804455473==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Micha=C5=82,

On 03/05/2019 12:56 PM, Micha=C5=82 Lowas-Rzechonek wrote:
> Hi Denis,
> =

> On 03/05, Denis Kenzior wrote:
>> Please, no top posting on this mailing list :)
> Sorry! Most MUAs nowadays default to top posting, my bad for not paying
> attention.

No worries.

> =

>> So my initial response would be in a form of a bewildered question: "Why=
 are
>> we even talking about this?".  The reason I ask is that we follow the
>> Linux kernel coding style, which basically disallows most of the
>> 'interesting' C99 features.
> Didn't mean to offend. Since I submitted a patch and I'm probably going
> to submit a few more, I wanted to know what to expect. I read the coding
> style, but ELL doesn't mention -std=3Dgnu89. I know it's probably
> "obvious" to you guys, since you have a kernel background, but many
> other projects have substantially different policies.

No, not at all, no offense taken.  I was just incredulous that this =

topic came up at all.  The coding style does mention that we use the =

Linux Kernel coding style, and if you study that one it becomes pretty =

clear that all the 'fun' features of C99 aren't allowed.  Also, if you =

violate the coding standard, then I will also likely mention it during =

the initial review ;)

> =

>> But since we are talking about this, let me formulate the official polic=
y.
>> We follow the same process as described in:
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/=
Documentation/process/programming-language.rst
>>
>> So roughly speaking what this means is that the code should compile with
>> -std=3Dgnu89.  C89 compliance is not an official policy or goal.
> Fair enough, thank you for clarification!
> =

> It might be worth to mention this in doc/coding-style, so a next
> clueless person doesn't repeat silly questions ;)
> =


In this country they say: 'There are no silly questions'.  Anyhow, point =

taken and I've added a reference to the Linux Kernel 'programming =

language process' document in commit: =

4c220dca8c7b13774a7af5cd7a3ed06ef4d88a73

Hopefully that makes things clearer.

Regards,
-Denis

--===============3184682964804455473==--

