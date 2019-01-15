Content-Type: multipart/mixed; boundary="===============5288545560514441996=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] genl: Handle empty data in l_genl_msg_append_attr
Date: Tue, 15 Jan 2019 07:42:13 -0600
Message-ID: <4a64d584-a6e7-f815-7b84-b17db25ab9fb@gmail.com>
In-Reply-To: <20190115062125.5202-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5288545560514441996==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/15/2019 12:21 AM, Andrew Zaborowski wrote:
> Make sure l_genl_msg_append_attr can be called with a NULL @data (when
> @len is 0) for attributes like nl80211 flags, without triggering an asan
> warning about the memcpy parameter being NULL.
> ---
>   ell/genl.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)

Applied, thanks.

Regards,
-Denis


--===============5288545560514441996==--

