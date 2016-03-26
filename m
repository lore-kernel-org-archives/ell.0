Content-Type: multipart/mixed; boundary="===============5263205513716967802=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 13/15] dbus: Add message filter public API.
Date: Fri, 25 Mar 2016 21:42:04 -0500
Message-ID: <56F5F6FC.3000204@gmail.com>
In-Reply-To: <CAOq732J_gp+2wfmqoLJfADR_7CgkbFRE7EZMDHqCY1oROO40Jw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5263205513716967802==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/25/2016 06:45 PM, Andrzej Zaborowski wrote:
> Hi Denis,
>
> On 24 March 2016 at 19:04, Denis Kenzior <denkenz@gmail.com> wrote:
>> Does it make sense to make glob-match values part of the tree?
>>
>> For example, I can install watch 1 with:
>> type=3D'signal', path=3D'/'
>>
>> and watch 2 with:
>> type=3D'signal', sender=3D'org.foo', path=3D'/'
>>
>> Right now it seems we will generate 2 AddMatch cases for the above, even
>> though watch 2 is already covered by watch 1.
>
> Ah, good point.  I think we could handle that also with the current
> structure if we allow the nodes to be added to the tree in any order
> necessary, so that the "sender=3D'org.foo'" could be a child of
> "path=3D'/'" in specific cases.  This wouldn't add any cost to the
> filtering of incoming signals, only to adding new rules, what do you
> think?
>

Could work, but my first thought is that it would cause lots of =

additional processing, since you'd be trying all possible permutations. =

  Given that we have 4-5 rules on average that's a lot of possibilities =

to try.  Or were you thinking something else?

Regards,
-Denis

--===============5263205513716967802==--

