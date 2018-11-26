Content-Type: multipart/mixed; boundary="===============7669531651508168775=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/5] key: Implement l_keyring_link_nested
Date: Mon, 26 Nov 2018 13:21:11 -0600
Message-ID: <786baf3e-c3ee-d179-4f46-735033d80fc1@gmail.com>
In-Reply-To: <20181123094429.7190-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7669531651508168775==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 11/23/2018 03:44 AM, Andrew Zaborowski wrote:
> Allow linking and unlinking keyrings to/from other keyrings with
> l_keyring_link_nested (naming proposed by Mat) and
> l_keyring_unlink_nested.
> ---
>   ell/ell.sym |  2 ++
>   ell/key.c   | 26 ++++++++++++++++++++++++++
>   ell/key.h   |  5 +++++
>   3 files changed, 33 insertions(+)
> =


Applied.  I added/amended the missing LIB_EXPORT bits in.

Regards,
-Denis


--===============7669531651508168775==--

