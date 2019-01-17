Content-Type: multipart/mixed; boundary="===============4938187037891191030=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] key: Unlink keys when revoking
Date: Thu, 17 Jan 2019 11:32:34 -0600
Message-ID: <a1c7a4a3-d6f6-3a04-3480-08bf81e0db5f@gmail.com>
In-Reply-To: <20190117171916.27960-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4938187037891191030==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/17/2019 11:19 AM, Andrew Zaborowski wrote:
> As an optimization unlink the key in l_key_free and l_keyring_free same
> as we do in l_key(ring)_free_norevoke, in addition to the actual
> revocation.  This happens to release the quota spot used by the key much
> faster under some circumstances.
> ---
>   ell/key.c | 15 +++++++++++++++
>   1 file changed, 15 insertions(+)
> =


All applied, thanks.

Regards,
-Denis


--===============4938187037891191030==--

