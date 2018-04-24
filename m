Content-Type: multipart/mixed; boundary="===============7353512739392025177=="
MIME-Version: 1.0
From: Stotland, Inga <inga.stotland@intel.com>
Subject: Re: Debug logging with ell
Date: Tue, 24 Apr 2018 21:54:25 +0000
Message-ID: <1524606863.3034.31.camel@intel.com>
In-Reply-To: <CAPyD+=AE=7WiOqCumVyvNCtPpWFFMiZKk6eeg0bLeOVcqHETxw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7353512739392025177==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama, Denis,
   A. =

On Tue, 2018-04-24 at 14:35 -0700, Othman, Ossama wrote:
> Hi Denis,
> =

> On Tue, Apr 24, 2018 at 1:30 PM, Denis Kenzior <denkenz@gmail.com>
> wrote:>
> > > Quick question: can I use l_debug() when I am dynamically linking
> > > with
> > > installed ell library (i.e., the one created with make install
> > > and
> > > linked as -lell)?
> > > Calling l_debug() generates no output, l_info() works just fine.
> > > =

> > =

> > I suspect you're the first to try this, so doesn't surprise me that
> > it
> > doesn't work.  I imagine the current setup fails because the shared
> > library
> > has its own section and the executable has its own.
> > =

> > Probably can be solved with some macro magic, but will require a
> > bit of
> > surgery inside ell...
> =

> This used to work for me, but prior to today the last time I tried
> enabling debug logging code was probably a couple of months ago.
> =


Most likely to do with memory sections. One additional piece of info in
case it's helpful:
The section denoted by __start___debug[] and __stop___debug[] appears
to be shorter by size of one struct l_debug_desc when linking with
-lell (compared when compiled with internal lib). =


Inga

--===============7353512739392025177==
Content-Type: application/x-pkcs7-signature
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"

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
Zg5mBVQoBK5apmk2/QnKNb/XBUyu62quyTXRahXz2KXRqznXj++7MiP2dYTRzC1XMK1lAgMBAAGj
ggIxMIICLTAdBgNVHQ4EFgQUzeWQY29S+1e6mTvizPBEGBE3JGUwHwYDVR0jBBgwFoAU2kEjnFqP
ca9Xgz4g0+Nl2wzLC9swZQYDVR0fBF4wXDBaoFigVoZUaHR0cDovL3d3dy5pbnRlbC5jb20vcmVw
b3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWluZyUyMENBJTIwNEIu
Y3JsMIGfBggrBgEFBQcBAQSBkjCBjzAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AuaW50ZWwuY29t
LzBpBggrBgEFBQcwAoZdaHR0cDovL3d3dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0
ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWluZyUyMENBJTIwNEIuY3J0MAsGA1Ud
DwQEAwIHgDA8BgkrBgEEAYI3FQcELzAtBiUrBgEEAYI3FQiGw4x1hJnlUYP9gSiFjp9TgpHACWeB
3r05lfBDAgFkAgEJMB8GA1UdJQQYMBYGCCsGAQUFBwMEBgorBgEEAYI3CgMMMCkGCSsGAQQBgjcV
CgQcMBowCgYIKwYBBQUHAwQwDAYKKwYBBAGCNwoDDDBLBgNVHREERDBCoCcGCisGAQQBgjcUAgOg
GQwXaW5nYS5zdG90bGFuZEBpbnRlbC5jb22BF2luZ2Euc3RvdGxhbmRAaW50ZWwuY29tMA0GCSqG
SIb3DQEBBQUAA4IBAQCoG+97GZuQEwQnuWIVQWcpVw1Ym/kJEGjRAiB8JMflkvaemGuUV/xS2ccg
o4V80bU6Ee3jhFp3DH8aiO068JigsTZRDt172E7E/p187o2M6FicC63aUgWW/FZfEaOXuky/8jdz
9oaWcDIwFm+L6vpSQrE5Wbk5sCX04SvRlJ6X/+KAWJGE5sU9lA4XB0yJapCCoVyNZln3H3PdSXC2
rdOl2HSUdGOvmIwNkaSLLaVgUjz6mFzzRi/64tOfROIQSEdBYNStKYCixc2KP/sWL6LtfW+sQVLZ
r+HHDskuWTuEbYxFinLxC1gayzk80cz9z4qMg5bQJWyClLIwh4qpnUpoMYICFzCCAhMCAQEwgZAw
eTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAkNBMRQwEgYDVQQHEwtTYW50YSBDbGFyYTEaMBgGA1UE
ChMRSW50ZWwgQ29ycG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3Vp
bmcgQ0EgNEICEzMAAE9zKgiM3IZosrQAAAAAT3MwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzEL
BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE4MDQyNDIxNTQyM1owIwYJKoZIhvcNAQkEMRYE
FGzJIaV9yZAupwiniys5XBuLq48EMA0GCSqGSIb3DQEBAQUABIIBAMUblXpfoQVPtHGxcaZ6yRbh
Sywzhah5V1sH+ZCa0td40dc5fTXpWezAE7B7+hV/WF9GjeVDKN2NuSMLjJnX+MIfUY/VV4rJiCe5
yg9VCLNL1QVct78YIEZNr4AvnnvgkLTxazSF0JDp1BGYPIUht6w6A75nGPXKL/GdfACxso0WJzFc
yE7yiF+SJLsHr6DVH7H3NqHm2eeERFjzSuZZ4I8hyiZE5T/JNfPsvnI3s2t8b6efNdM74zmHyK1a
OU3oCESU5WpQy4cevq/O1AlTpWF47qnzBJjh62yWAJBOQNIfxMSkVhnu9vv+lZFJZd3wy3uHR1i3
YCryRG8y3TV5+vQAAAAAAAA=
--===============7353512739392025177==--

