Content-Type: multipart/mixed; boundary="===============1898800145469096159=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Tue, 17 Feb 2015 10:41:34 -0600
Message-ID: <54E36F3E.1010101@gmail.com>
In-Reply-To: <54E30E65.4030405@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1898800145469096159==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tomasz,

 >
> It's nice to get such goal clarifications, the earlier the better
> though: it was not as clear as that when we started.

Seriously? Remember, 'Embedded Linux Library'.  I think the focus is =

pretty clear ;)

>
> If memory is at stake, why promoting a bit of performance via storing
> the hash per-entry in the hashmap?

Because you do want to re-compute the hash, that is expensive. =

Especially since the hash can be supplied by the user and could be =

arbitrarily expensive computationally.

> Why also enabling the storage of the same key multiple times?
> (though that should not be an issue if the code is made without bug, but
> anyway the library should help just a bit when it's not too costly.)

ELL has been designed with existing usage in mind.  We looked at what =

BlueZ, oFono, ConnMan, neard, etc are doing and designed the API around =

that.  The goal is to make an API that would be fairly close to what =

we're already doing today.  This would make our future porting efforts =

easier.

You will find that most of our code uses lookup then insert with no =

possibility of duplicates.  So as I pointed out earlier, I don't see a =

need to detect duplicates at the cost of traversing the collision queue. =

  Simply put, if it ain't broke, don't fix it.

>
> Why also copying the key in the hashmap, when this could be wisely
> shared with the structure it points to?
> I am thinking about the network's object path. We rebuilt the object
> path dynamically, when we could be using just the same pointer.
> It would only require to be careful not to destroy a network structure,
> before removing its entry in the hash.
> (here it's a win/win on memory/performance)

Which hash are you talking about? And we have a path and an id that we =

generate.  You might be able to optimize one, but not the other.

Anyway, can be done and might even be a good idea.  But how is this =

relevant to the discussion about re-entrancy?

>
>
> On list - or queues - what are the arguments about using dynamically
> allocated ones vs the linux "list.h" way for instance?
> Isn't the later one a bit better from memory point of view if it would
> be single linked one (as it is not if I remember well)?
> (though the syntax is odd I agree, taste issue issue here so it's
> subjective).
>

We looked into that and decided against it.  Yes it is a bit more =

efficient storage wise if used right, but the syntax is painful.  It is =

also not really what we're used to (see above).

Regards,
-Denis

--===============1898800145469096159==--

