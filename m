Received: from mail3.hpi.uni-potsdam.de (mail3.hpi.uni-potsdam.de [141.89.225.123])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A15FA63B8
	for <ell@lists.linux.dev>; Sun, 21 May 2023 16:19:28 +0000 (UTC)
Received: from MX2018-DAG1.hpi.uni-potsdam.de (unknown [192.168.32.11])
	by mail3.hpi.uni-potsdam.de (Postfix) with ESMTPS id 2CA6FE8821
	for <ell@lists.linux.dev>; Sun, 21 May 2023 18:19:26 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hpi.uni-potsdam.de;
	s=201701; t=1684685966;
	bh=aLfO/f4aoOIsMb/8FflbcmJi2T6ci6WYl+j91yqAIkA=;
	h=From:To:Subject:Date:From;
	b=M8t8CLYFfP3NHSPfldbMedgf8MJGM5y2mTluPLpRjNYFANO8/GLOyC1C+jRNXnKY4
	 cYJI4EZSYn4XwrISgSAIbfNiFq/g/tvTCDpCvLw+qQZXEZCpgbqiqJW6+6HKX0OST5
	 JgqsFA74oMB6Ww9RlwV4fS1ooA9jdZa5YNcMSOpRF0Lk9Hn/6ipWhXxV0lP3qiCwyZ
	 HVXPVv8Tsa2Z2Hs9u0NFu+uhybqp1zvVT1t+BxbJhZjGBv/m4xhmfbJwM1Or3BNvcZ
	 5+5RdmRgXbKPt5U+lftsIgQZhxdmN8xseT1HR4TjsgXmpmc6b6bsx95isY8yKe3GLe
	 SC2Qu3jm/op8Q==
Received: from MX2018-DAG2.hpi.uni-potsdam.de (2001:638:807:200::b:16) by
 MX2018-DAG1.hpi.uni-potsdam.de (2001:638:807:200::b:b) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.2507.23; Sun, 21 May 2023 18:19:25 +0200
Received: from MX2018-DAG2.hpi.uni-potsdam.de ([fe80::49a2:3181:d674:f060]) by
 MX2018-DAG2.hpi.uni-potsdam.de ([fe80::49a2:3181:d674:f060%8]) with mapi id
 15.01.2507.023; Sun, 21 May 2023 18:19:25 +0200
From: "Ackermann, Eric" <Eric.Ackermann@student.hpi.uni-potsdam.de>
To: "ell@lists.linux.dev" <ell@lists.linux.dev>
Subject: [PATCH] Y2038 bug on uClibc: Warn if sizeof(time_t) < 8 during
 configuration
Thread-Topic: [PATCH] Y2038 bug on uClibc: Warn if sizeof(time_t) < 8 during
 configuration
Thread-Index: AQHZi//HSJ4MyCc9YUOUDz0JWuA6kA==
Date: Sun, 21 May 2023 16:19:25 +0000
Message-ID: <eee3edcf43a547e1bd8d4f09ea46c168@student.hpi.uni-potsdam.de>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [141.89.225.172]
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0

Hello everyone,

I discovered a Y2038 bug in iwd that was caused by the TLS certificate pars=
ing code in ell.
I compiled iwd for Linux with uClibc on armv7l. The test "EAPoL/8021x EAP-T=
LS & 4-Way=20
Handshake" failed with an assertion failure, as ell considered the certific=
ate used in the=20
test invalid. The reason for this is that the expiration date of the test c=
ertificate was in 2050,
which cannot be represented in uClibc's 4-byte time_t. Hence, timegm() fail=
s, causing a=20
failure of cert_parse_asn1_time() and so on.
I reckon that the issue is specific to uClibc and other C libraries that us=
e a 4-byte time_t on
32 bit platforms, e.g., uClibc as configured by buildroot. Most C libraries=
 (e.g. glibc, musl)=20
simply define time_t to always be 64 bits long, avoiding the issue.
However, especially on embedded systems that use uClibc, this is a real iss=
ue that might=20
cause unexpected behavior. Unfortunately, to my knowledge, there is no port=
able version
of timegm that=A0always uses a 64-bit output. However, in my opinion, I bel=
ieve that the C=20
library rather than ell should be changed. For the time being (and for user=
s who use=20
unpatched versions of C libraries), the appended patch adds a warning to co=
nfigure in case=20
sizeof(time_t) < 8 bytes.

Kind regards,
Eric Ackermann
---
=A0configure.ac | 12 ++++++++++++
=A01 file changed, 12 insertions(+)

diff --git a/configure.ac b/configure.ac
index fb7a997..23e719b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -31,6 +31,18 @@ AC_C_BIGENDIAN(little_endian=3Dno, little_endian=3Dyes, =
little_endian=3Dno)
=A0LT_PREREQ(2.2)
=A0LT_INIT([disable-static])

+AC_CHECK_SIZEOF([time_t])
+SIZEOF_TIME_T=3D$($AWK '/SIZEOF_TIME_T/{print $3}' confdefs.h)
+if (test "${SIZEOF_TIME_T}" -lt "8"); then
+=A0=A0=A0=A0=A0=A0 AC_MSG_WARN([sizeof(time_t) is less than 8 bytes on you=
r
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 platform. Hence,=
 dates after 2038-01-19 cannot be
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 represented in a=
 time_t. This might lead to overflow
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 errors in time p=
rocessing functions such as timegm,
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 which can manife=
st themselves e.g. by TLS certificates
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 with an expirati=
on date after 2038 not being accepted
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 by ell. Proceed =
with caution.])
+fi
+
=A0AC_ARG_ENABLE(optimization, AS_HELP_STRING([--disable-optimization],
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [disa=
ble code optimization through compiler]), [
=A0=A0=A0=A0=A0=A0=A0 if (test "${enableval}" =3D "no"); then
--
2.25.1=
