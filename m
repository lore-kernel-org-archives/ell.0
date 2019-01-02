Content-Type: multipart/mixed; boundary="===============1894346142282678262=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 13/17] key: Add l_key_validate_dh_payload
Date: Wed, 02 Jan 2019 23:54:41 +0100
Message-ID: <CAOq732+=p5ZVA=f3k15P4qHfvyMUfyWQzjC-dMgiA7Atga7-Xw@mail.gmail.com>
In-Reply-To: <f33209a3-d93b-85c0-b7d6-40985304abbd@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1894346142282678262==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Wed, 2 Jan 2019 at 21:47, Denis Kenzior <denkenz@gmail.com> wrote:
> On 01/01/2019 01:49 PM, Andrew Zaborowski wrote:
> > Add a function to validate local private value payloads against a
> > the group's prime before creating kernel keys out of them, and to
>
> Do we have the same issue in iwd EAP-WSC?

I was going to send a patch for that later, we probably should
validate the values but obviously the probability of the check failing
in the first iteration is vert low.  In TLS I guess it's higher
because we may have to deal with a custom prime, but I didn't add this
because of actually hitting a problem.

>
> > validate public values received from the peer.
>
> Note that the kernel already performs almost the same check in
> dh_is_pubkey_valid

Oh true, this was apprently added in July.  So as far as I understand
that function is called in dh_compute so our compute_dh_secret should
fail.  But, in unit/test-key we have this "dh_degenerate" test case
and it's passing, I have to look at when this check is supposed to
trigger in the kernel, maybe we can still use it.

>
> Might make more sense to create an API to generate a valid private key
> with the needed constraints.

Yep, may be a good idea, and this could hide the 256 byte limit for
l_getrandom too (I was also thinking maybe l_getrandom itself should
try to hide that detail)

> E.g. by twiddling the MSBs to 0 until the
> private key is less than the prime.

I think this is not normally done so as not to affect the probability
distribution of the private values.  But we probably should at least
clear the top few bits of the random number that we know have to be 0
for the number to be lower than the prime.  A TLS client can
potentially a receive a prime from the server that has 01 in the first
byte and then on average it'd need 256 iterations before it draws a
value lower than the prime the naive way.

Best regards

--===============1894346142282678262==--

