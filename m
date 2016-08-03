Content-Type: multipart/mixed; boundary="===============2681264263209574357=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 2/2] hwdb: Optimize lookup execution
Date: Wed, 03 Aug 2016 11:20:29 -0700
Message-ID: <alpine.OSX.2.20.1608031051090.37847@mjmartin-mac01.local>
In-Reply-To: <20160802192120.14887-2-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2681264263209574357==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, 2 Aug 2016, Mat Martineau wrote:

> Decide whether to descend into child nodes based on fnmatch() results,
> rather than performing a depth-first search of all nodes.
>
> Using test-hwdb as an example, it now takes an average of ~50 calls to
> trie_fnmatch to perform a lookup instead of ~100000.

Before I forget, the other potential trie_fnmatch optimization I spotted =

was to reduce stack usage. alloca isn't expensive in terms of runtime, but =

there's no reason to have so many copies of pattern prefixes sitting =

around. It would work to allocate a pattern buffer at the beginning. The =

matching pattern will not typically be longer than the string being =

matched, but '*' may match nothing so reallocs would be a possibility.

--
Mat Martineau
Intel OTC

--===============2681264263209574357==--

