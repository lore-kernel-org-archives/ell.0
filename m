Content-Type: multipart/mixed; boundary="===============2741114840947000265=="
MIME-Version: 1.0
From: Phil Hodges <philip.hodges@bluewin.ch>
Subject: overflow with 32 bit time_t: fixed in path but not time, no unit test
Date: Sat, 14 Mar 2020 12:03:12 +0100
Message-ID: <6a282fd5-6252-e8fa-725b-d92d31c247ec@bluewin.ch>
In-Reply-To: <323CFD33-9B37-4089-BFE4-7D9CBBAA8C8C@bluewin.ch>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2741114840947000265==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

./ell/ell/time.c:46:	return now.tv_sec * 1000000 + now.tv_nsec / 1000;
./ell/ell/path.c:165:	return (uint64_t) sb.st_mtim.tv_sec * 1000000 +

--===============2741114840947000265==--

