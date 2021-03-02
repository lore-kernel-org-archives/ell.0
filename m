Content-Type: multipart/mixed; boundary="===============5270107459383468144=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] queue: Fix an l_queue_insert corner case
Date: Tue, 02 Mar 2021 10:30:11 -0600
Message-ID: <13b878b3-d2f4-ae69-e39a-82d5dc6c0035@gmail.com>
In-Reply-To: <CAOq732+bJkphExwAf7A38QRP0aE9q_tP7rVS4tRQD9FV+2Nfog@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5270107459383468144==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> Right, or about the treatment of any other value.
> =

> With this wording I'm pretty sure anyone you ask is going to interpret th=
is as:
> =

>   - insert after current entry if returned value > 0
>   - insert before current entry otherwise
> =

Just FYI, this is class modeled on the Gnome API:
https://developer.gnome.org/glib/stable/glib-Singly-Linked-Lists.html#g-sli=
st-insert-sorted

I don't recall whether it actually works the same way as you interpret it. =
 They =

do document GCompareFunc, which might make things more or less ambiguous.

>>
>>> however the function would insert @data after entries for which
>>> @function returned a >=3D 0 value.  Change the check to > 0 to align wi=
th
>>> the docs.
>>
>> The intent is that values that are 'equal' (@function returns 0) are ins=
erted
>> _after_ any entries already in the queue.  While not documented explicit=
ly, I'm
>> pretty sure that this is the only sensible behavior (and likely somethin=
g we
>> implicitly rely on).  So, I'm not sure this is the right fix?

This change:
'git show 13225cb2efd070618122abbae3c1b23600527658'

came about because someone came to a different conclusion and assumed the e=
ntry =

would be inserted afterwards.  I'm fuzzy now on the details, likely it was =
the =

scanning code in iwd.

> =

> We can change the docs to much that intent then...
> =


Sure.

Regards,
-Denis
--===============5270107459383468144==--

