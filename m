Content-Type: multipart/mixed; boundary="===============4549626922461859375=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 13/15] dbus: Add message filter public API.
Date: Sun, 27 Mar 2016 05:48:13 +0200
Message-ID: <CAOq732L9bQYs+v8hGJJbo+CHxCt1167fws8i2pzMX5krBT-wdw@mail.gmail.com>
In-Reply-To: <56F704EB.5070402@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4549626922461859375==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 26 March 2016 at 22:53, Denis Kenzior <denkenz@gmail.com> wrote:
> On 03/26/2016 10:22 AM, Andrzej Zaborowski wrote:
>> On 26 March 2016 at 03:42, Denis Kenzior <denkenz@gmail.com> wrote:
>>> On 03/25/2016 06:45 PM, Andrzej Zaborowski wrote:
>>>> I think we could handle that also with the current
>>>> structure if we allow the nodes to be added to the tree in any order
>>>> necessary, so that the "sender=3D'org.foo'" could be a child of
>>>> "path=3D'/'" in specific cases.  This wouldn't add any cost to the
>>>> filtering of incoming signals, only to adding new rules, what do you
>>>> think?
>>>>
>>>
>>> Could work, but my first thought is that it would cause lots of
>>> additional
>>> processing, since you'd be trying all possible permutations.  Given that
>>> we
>>> have 4-5 rules on average that's a lot of possibilities to try.  Or were
>>> you
>>> thinking something else?
>>
>>
>> There would be some additional processing but I think it may be okay.
>> Now when adding a new rule and we're at a specific node in the tree
>> we're checking if there's already a child that matches the next
>> condition in the rule.  Instead we could check if there's a match for
>> any of the yet unused conditions in the rule, and mark that condition
>> as used or "visited".  In the typical case where most rules begin with
>> a sender value this wouldn't add any overhead I think.
>>
>
> Lets give it a shot.  I ran some mental exercises and can't seem to find =
any
> negatives to the idea besides increasing the add filter cost by a factor =
of
> n, where n =3D number of rules being added.
>
> The upside is that we could also get rid of the qsort this way.  The sile=
nt
> side-effecting of the input rules is less than ideal.

True, but I was actually thinking that we could use the fact that the
elements were already sorted to add some optimization and also that,
even though the tree's shape would be harder to predict, it wlil
probably still be more memory efficient than without sorting.

One optimization would be that when adding a rule to the tree, for
every child node we only have to walk the list of conditions until the
condition type enum is bigger or equal to the child's type enum.  For
the easy scenarios that'd mean we only have to compare every child
against one rule condition like we're doing now.

Best regards

--===============4549626922461859375==--

