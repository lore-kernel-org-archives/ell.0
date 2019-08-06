Content-Type: multipart/mixed; boundary="===============4187682765366285250=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp: fix T1 timeout crash
Date: Tue, 06 Aug 2019 15:50:33 -0500
Message-ID: <219dc345-9ed1-e168-01d8-7d540bdd8e04@gmail.com>
In-Reply-To: <20190806204628.17351-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4187682765366285250==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 8/6/19 3:46 PM, James Prestwood wrote:
> The timeout user data was being passed as the address to the
> client object, not the client object itself.
> ---
>   ell/dhcp.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis


--===============4187682765366285250==--

