Content-Type: multipart/mixed; boundary="===============5494161631342648511=="
MIME-Version: 1.0
From: Thomas Petazzoni <thomas.petazzoni@bootlin.com>
Subject: Re: [PATCH 1/3] ell: cast printf call to double
Date: Wed, 22 Jul 2020 14:51:27 +0200
Message-ID: <20200722145127.44999192@windsurf.home>
In-Reply-To: <20200721223959.87135-1-rosenp@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5494161631342648511==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, 21 Jul 2020 15:39:57 -0700
Rosen Penev <rosenp@gmail.com> wrote:

> %f confusingly enough takes a bool, not a float.

takes a _double_, most likely not a bool :-)

Thomas
-- =

Thomas Petazzoni, CTO, Bootlin
Embedded Linux and Kernel engineering
https://bootlin.com
--===============5494161631342648511==--

