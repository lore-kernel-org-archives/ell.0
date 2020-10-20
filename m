Content-Type: multipart/mixed; boundary="===============0335709889416547798=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] io: Always call read handler on EPOLLIN
Date: Tue, 20 Oct 2020 10:01:29 -0500
Message-ID: <79732ba9-9a90-1e40-b4ef-b52e91df2697@gmail.com>
In-Reply-To: <20201018060645.37208-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0335709889416547798==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

On 10/18/20 1:06 AM, Inga Stotland wrote:
> When detecting EPOLLIN, always invoke read handler first.
> This ensures that even when error conditions (i.e., EPOLLHUP
> and/or EPOLLERR) are encountered, any residual data is still
> delivered to the client.
> ---
>   ell/io.c | 16 ++++++++--------
>   1 file changed, 8 insertions(+), 8 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis

--===============0335709889416547798==--

