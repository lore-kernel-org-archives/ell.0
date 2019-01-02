Content-Type: multipart/mixed; boundary="===============5405681880073578468=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 13/17] key: Add l_key_validate_dh_payload
Date: Wed, 02 Jan 2019 14:47:33 -0600
Message-ID: <f33209a3-d93b-85c0-b7d6-40985304abbd@gmail.com>
In-Reply-To: <20190101194939.5974-13-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5405681880073578468==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/01/2019 01:49 PM, Andrew Zaborowski wrote:
> Add a function to validate local private value payloads against a
> the group's prime before creating kernel keys out of them, and to

Do we have the same issue in iwd EAP-WSC?

> validate public values received from the peer.

Note that the kernel already performs almost the same check in =

dh_is_pubkey_valid

Might make more sense to create an API to generate a valid private key =

with the needed constraints.  E.g. by twiddling the MSBs to 0 until the =

private key is less than the prime.

> ---
>   ell/ell.sym |  1 +
>   ell/key.c   | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
>   ell/key.h   |  3 +++
>   3 files changed, 52 insertions(+)
> =


Regards,
-Denis

--===============5405681880073578468==--

