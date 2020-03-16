Content-Type: multipart/mixed; boundary="===============0317231578658821104=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: overflow with 32 bit time_t: fixed in path but not time, no unit
 test
Date: Mon, 16 Mar 2020 15:59:35 +0000
Message-ID: <2b2db228-020b-f118-4920-a0fb5646737f@gmail.com>
In-Reply-To: <6a282fd5-6252-e8fa-725b-d92d31c247ec@bluewin.ch>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0317231578658821104==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Phil,

On 3/14/20 6:03 AM, Phil Hodges wrote:
> ./ell/ell/time.c:46:=C2=A0=C2=A0=C2=A0 return now.tv_sec * 1000000 + now.=
tv_nsec / 1000;
> ./ell/ell/path.c:165:=C2=A0=C2=A0=C2=A0 return (uint64_t) sb.st_mtim.tv_s=
ec * 1000000 +

Thanks for reporting this.

Should now be fixed upstream by:
c68b4c1e6097 ("time: Fix overflow on 32-bit systems")

Regards,
-Denis
--===============0317231578658821104==--

