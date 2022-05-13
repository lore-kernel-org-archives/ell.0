Content-Type: multipart/mixed; boundary="===============4615381814816100046=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 03/13] netconfig: Create routes from Router Advertisements
Date: Fri, 13 May 2022 08:39:48 -0500
Message-ID: <c5cc45af-3e21-f783-2bd6-115ef3cde673@gmail.com>
In-Reply-To: CAOq732JpUSNHdFaOE=0eXbXd-a+sP0RT0cftP3w17usBQ8dmEQ@mail.gmail.com

--===============4615381814816100046==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> Ugh, can we use l_queue_get_entries loop directly or a helper function i=
nstead?
> =

> Ok.  We could also add a l_queue_match_ptr in queue.h since IIRC we
> also have a copy in IWD.
> =


I don't like the idea of adding a matching function for comparing pointers.=
  How =

about l_queue_find_ptr() instead?

Regards,
-Denis
--===============4615381814816100046==--

