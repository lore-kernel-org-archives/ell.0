Content-Type: multipart/mixed; boundary="===============6705531782173825158=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/2] fswatch: Add fswatch API
Date: Fri, 20 Jul 2018 19:41:45 +0200
Message-ID: <CAOq732++BS8+R3nHR_k5hwgM1D9412jh5bmtXKauQ2m5LOw00A@mail.gmail.com>
In-Reply-To: <CAOq732+7cQKBpYh9pFLne=WBwnJUBky9kJBYsofHiGsoq1xGMw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6705531782173825158==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 20 July 2018 at 19:37, Andrew Zaborowski <andrew.zaborowski@intel.com>=
 wrote:
> The loop is wrong though and would cause valgrind to complain because
> after your last iteration ptr equals buf + len, so 'event' also points
> at the end of buf and event->len is beyond the end of your buffer.

Uhh no, it's actually only checking that ptr < buf + len, I'm not
reading correctly today.

Best regards

--===============6705531782173825158==--

