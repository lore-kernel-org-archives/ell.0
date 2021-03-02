Content-Type: multipart/mixed; boundary="===============1672409415179856438=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] queue: Be more specific in l_queue_insert comment
Date: Tue, 02 Mar 2021 16:53:53 -0600
Message-ID: <58d95cce-9a0b-6050-7a3c-cfd8d52ad9c0@gmail.com>
In-Reply-To: <20210302215453.777869-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1672409415179856438==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 3/2/21 3:54 PM, Andrew Zaborowski wrote:
> Specify that entries for which the compare function returns a 0 come
> before the new entry.
> ---
>   ell/queue.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
> =


Applied, thanks.

Regards,
-Denis
--===============1672409415179856438==--

