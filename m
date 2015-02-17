Content-Type: multipart/mixed; boundary="===============5541328004950295375=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Tue, 17 Feb 2015 11:48:21 +0200
Message-ID: <54E30E65.4030405@linux.intel.com>
In-Reply-To: <B8BC2303-DDA8-48EC-876D-D4820A23541A@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5541328004950295375==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel and Denis,

> I am just mentioning this here so that everybody understands what our goa=
ls here. We might be utilizing systems where the userspace is small and rea=
lly limited. What ELL needs to do is provide common functionality for its u=
sers, but it does not have to solve world hunger for its users.

It's nice to get such goal clarifications, the earlier the better =

though: it was not as clear as that when we started.

That said, there are misleading signals about these. I'll be annoying =

about hashmap, last time:

If memory is at stake, why promoting a bit of performance via storing =

the hash per-entry in the hashmap?
Why also enabling the storage of the same key multiple times?
(though that should not be an issue if the code is made without bug, but =

anyway the library should help just a bit when it's not too costly.)

Why also copying the key in the hashmap, when this could be wisely =

shared with the structure it points to?
I am thinking about the network's object path. We rebuilt the object =

path dynamically, when we could be using just the same pointer.
It would only require to be careful not to destroy a network structure, =

before removing its entry in the hash.
(here it's a win/win on memory/performance)


On list - or queues - what are the arguments about using dynamically =

allocated ones vs the linux "list.h" way for instance?
Isn't the later one a bit better from memory point of view if it would =

be single linked one (as it is not if I remember well)?
(though the syntax is odd I agree, taste issue issue here so it's =

subjective).


And about the non-dbus, non-netlink ways, this would require a complete =

rewrite of the targeted projects since these are
not architectured at all for that. That's also quite new as a goal.


Cheers,

Tomasz

--===============5541328004950295375==--

