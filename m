Content-Type: multipart/mixed; boundary="===============1931604473480487042=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 5/6] netconfig: Add l_netconfig_apply_rtnl
Date: Tue, 08 Feb 2022 12:31:03 -0600
Message-ID: <957cac35-0017-babd-7ec3-8dc9d4d3ac77@gmail.com>
In-Reply-To: CAOq732+SYSuUpUCVtNiuSt-FFbX9zY7K00CAdkSd91WY6Uro1A@mail.gmail.com

--===============1931604473480487042==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>>> I wonder if we can use const l_queue_entry * instead.  Or maybe some so=
rt of
>>> iterator concept?  Returning a pointer to the internal data structure is
>>> something we should only do as a last resort.
>>
>> "const l_queue_entry *" would work.  We can also just transfer the
>> ownership of those three lists to the caller and drop our references
>> to those three lists when we return them.  They're actually temporary,
>> I just used l_queue_clear instead of destroying and recreating them.
> =

> (This doesn't apply to the complete list of addresses/routes that we
> also return, you're right that we'd need to return an iterator.
> struct l_queue_entry is pretty much an iterator except that the
> .next/.data members are public)
> =


Okay.  See what you can come up with.  If l_queue_entry works, that would l=
ikely =

be the easiest approach.

Regards,
-Denis
--===============1931604473480487042==--

