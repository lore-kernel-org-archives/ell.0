Content-Type: multipart/mixed; boundary="===============0645619346285145894=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v3 2/5] unit: Add race condition test to test-main
Date: Thu, 17 Mar 2016 11:17:22 -0700
Message-ID: <alpine.OSX.2.20.1603171116320.20661@mjmartin-mac01.local>
In-Reply-To: <1458238542-11711-2-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0645619346285145894==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Thu, 17 Mar 2016, Mat Martineau wrote:

> This test excercises the case where multiple events are returned from

Oops, should be "exercises"

> the same epoll_wait call and an early event deletes a watch that is
> waiting to be processed in the same event loop iteration.


--
Mat Martineau
Intel OTC



--===============0645619346285145894==--

