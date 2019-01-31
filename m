Content-Type: multipart/mixed; boundary="===============6760999762190967916=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] key: Use KEYCTL_INVALIDATE in l_key_free
Date: Thu, 31 Jan 2019 12:33:16 -0600
Message-ID: <3bae4dda-20e6-3e9e-1f78-da8013797b57@gmail.com>
In-Reply-To: <20190131175659.8150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6760999762190967916==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/31/2019 11:56 AM, Andrew Zaborowski wrote:
> Replace the use of KEYCTL_REVOKE with KEYCTL_INVALIDE in
> l_key(ring)_free.  10ff938dc758e36135c1e07370c2d06cf89d8620 improved the
> behaiour of l_key_free with regards to the key quota freeing for cases
> when the key was only linked to the internal session keyring.  By using
> KEYCTL_INVALIDATE we can achieve the same effect even if the key is
> still linked to multiple keyrings and with just one operation instead of
> two.  keyctl(2):
> =

> KEYCTL_REVOKE (since Linux 2.6.10)
> [...]
> Revoke  the  key  with  the ID provided in arg2 (cast to key_serial_t).
> The key is scheduled for garbage collection;
> =

> (In practice this means the key gets freed after 5 minutes)
> =

> KEYCTL_INVALIDATE (since Linux 3.5)
> [...]
> This operation marks the key as invalid and schedules immediate garbage
> collection.  The garbage collector removes  the  invalidated  key  from
> all keyrings and deletes the key when its reference count reaches zero.
> ---
>   ell/key.c | 24 +++++++-----------------
>   1 file changed, 7 insertions(+), 17 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============6760999762190967916==--

