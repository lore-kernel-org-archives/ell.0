Content-Type: multipart/mixed; boundary="===============0501415858453554299=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: REQ: revert e129cb4cd2270f308c1564e75859672643dd902b (plugin:
 Remove completely)
Date: Fri, 08 Jan 2021 14:42:03 -0600
Message-ID: <1170cf9a-21eb-66b0-20a5-e4fa17cea3a9@gmail.com>
In-Reply-To: <899339e7-f6bf-46f8-a7ff-93085b8e7a6b@www.fastmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0501415858453554299==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Shawn,

On 1/8/21 11:49 AM, Shawn Nock wrote:
> https://git.kernel.org/pub/scm/libs/ell/ell.git/commit/?id=3De129cb4cd227=
0f308c1564e75859672643dd902b
> =

> I cannot find any discussion of the removal on the mailing list archive a=
nd as far as I can tell the patch wasn't sent to the list before commit. Th=
e commit says that there are no users. We use the plugin functionality.

Indeed, there was no mailing list announcement.  In retrospect, we should h=
ave =

done so.

Note that we have not made any API/ABI stability promises as yet, so ell is =

still a moving target.  We have had no real reason to do so as we were not =
aware =

of any ell users outside of the core projects that we support (iwd, bluez, =

mptcpd, etc).

We have been wanting to make this particular change for a while.  The catal=
yst =

for the decision were reports of build issues on certain linkers with iwd/e=
ll. =

Since we were about to make a release, instead of adding hot-fixes, which w=
ere =

objected to by some developers, we decided to take the whole thing out.  Th=
is =

was done after consulting with all known users of ell on IRC.

> =

> I can, of course, maintain this functionality separately. Plugin function=
ality is a fairly common pattern and while the current implementation isn't=
 particularly nice, I did enjoy not having to re-implement it.

As you point out, the current implementation wasn't that hot, and there wer=
e no =

users among the core projects that we support.

If you want to add this back in, then it probably should be made into its o=
wn =

mini-library.  Something like 'ell-plugin'; any users would have to explici=
tly =

opt-in to use it rather than it being a part of the core ell library.

Regards,
-Denis
--===============0501415858453554299==--

