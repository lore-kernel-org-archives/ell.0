Content-Type: multipart/mixed; boundary="===============3750154412748451580=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 13/15] dbus: Add message filter public API.
Date: Sat, 26 Mar 2016 00:45:24 +0100
Message-ID: <CAOq732J_gp+2wfmqoLJfADR_7CgkbFRE7EZMDHqCY1oROO40Jw@mail.gmail.com>
In-Reply-To: <56F42C31.5090105@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3750154412748451580==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 24 March 2016 at 19:04, Denis Kenzior <denkenz@gmail.com> wrote:
> Does it make sense to make glob-match values part of the tree?
>
> For example, I can install watch 1 with:
> type=3D'signal', path=3D'/'
>
> and watch 2 with:
> type=3D'signal', sender=3D'org.foo', path=3D'/'
>
> Right now it seems we will generate 2 AddMatch cases for the above, even
> though watch 2 is already covered by watch 1.

Ah, good point.  I think we could handle that also with the current
structure if we allow the nodes to be added to the tree in any order
necessary, so that the "sender=3D'org.foo'" could be a child of
"path=3D'/'" in specific cases.  This wouldn't add any cost to the
filtering of incoming signals, only to adding new rules, what do you
think?

Best regards

--===============3750154412748451580==--

