Content-Type: multipart/mixed; boundary="===============5402246135303621975=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH 4/4] path: Use l_timespec_to_usecs() to avoid overflow.
Date: Mon, 02 Mar 2020 15:13:15 -0800
Message-ID: <CAPyD+=CVX+oexu4Y_ywv1m8KzFhmD3R2Cdv5j-tbX8P7pvDvJg@mail.gmail.com>
In-Reply-To: <6d498de9-6ea7-1f26-e158-c1b743f8c5da@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5402246135303621975==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Mon, Mar 2, 2020 at 2:06 PM Denis Kenzior <denkenz@gmail.com> wrote:
> So while theoretically possible to overflow, this is _highly_ unlikely.
> I think we are looking at 35-36 bits of sec info, which is 1-2 thousand
> years in the future.

That's a good point.

> I guess I'm ok if we try and deal with overflow just in case someone is
> setting some really large mtime values as long as l_timespec_to_usecs
> isn't overly expensive.

As you point out that the overflows are highly unlikely to occur, I'm
fine with dropping my patches.

Thanks Denis!
-Ossama
--===============5402246135303621975==--

