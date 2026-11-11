Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=212.227.17.20
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794413970;
	b=achnUWpPPaniNH2HrkJa3tAGzGwQQWSXahsAGgSBwg3LhAAGGITAavXwzcMSl0J9Cm5l
	 A58LvBH4oRwSfSU/f0OePh0b2N3rhfXR0IP3d1WXdb4OgTCyml/N7jjewhlHTTl9x+8E0
	 /tnOWH2suasw7EhkrwSKkJEGIg2PVui7XXE/+hTC8GGn6b0ZsmkHDykmCpp+j7QXsI6Gc
	 PDbpTQCB+DThbvYwE16EEzxrbQKQaM4iRCEtMHt25Jb05hSagbrJkwTZDFJXZT/S/Jh3s
	 Zzf9kzAHww0OFwuzmKivzju8/myek+ru2nbH/4N3XZoZVOkemGcvLpjjn5ytxpigo5A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794413970;
	h=DMARC-Filter:DKIM2-Signature:Message-Instance:DKIM-Signature:
	 X-UI-Sender-Class:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding:X-Provags-ID:
	 X-Spam-Flag:UI-OutboundReport;
	bh=0n/XOOfVUiXylXawprcUPz/nyE3SrDlWH2QD2dFNhgU=;
	b=llcBQrrXCHPYxYAK9DnUsQJxiUFhKvvDST6hx9ZZ1Ebe5zR+P62tW2BN+M8ArHTflFW7
	 gqF7X9wy4oiERtBn5ymC8Y2tHgQCcV08YFDLssphHy1KztsnHP4p4/6QE8sUB6Bkq2LLF
	 ew0i0HiRCWHk6Rqi7Gv/6I/sb3e2VV9wrSvpTjShVXR9ZiGYYfdRPV2nKobGkL4AfaQW1
	 3WnOUwvDq7v8OxCsvedtd13UlLDsCTs0rjAQZa3CLOJuubzrO8+tiH3PwMtPHjVkUwhHZ
	 x7ne8RaRixWMXvh8pUlG6GYIgu3yyry8g/UbMTQ8hKu8X9sqW6mRKT7WAzfOtg56E8Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmx.net;
	spf=pass smtp.mailfrom=gmx.net;
	dkim=pass header.d=gmx.net header.i=alexander.hoelzl@gmx.net header.a=rsa-sha256 header.s=s31663417 header.b=BclIHpQw;
	arc=none smtp.remote-ip=212.227.17.20
Received: from mout.gmx.net (mout.gmx.net [212.227.17.20])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (prime256v1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76B7D606A32D
	for <ell@lists.linux.dev>; Wed, 11 Nov 2026 16:19:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 76B7D606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmx.net header.i=alexander.hoelzl@gmx.net header.a=rsa-sha256 header.s=s31663417 header.b=BclIHpQw
DKIM2-Signature:  i=1; m=1; t=1794413967;
 mf=PGFsZXhhbmRlci5ob2VsemxAZ214Lm5ldD4=;
 rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
 d=gmx.net;
 s=s31663417:rsa-sha256:cGTTaKEKGhbyWabIKqOZJBSnLQ0q
   c7dorjeNhsMOmp3+UID3ncwqPZkNuquL7XqXRoh7yB5IDxeLe50mkWWtUlfoyehTHlaDZyt/X78
   aOHACXkllK2uZxkWo5ZObnXh9AQsammMGZsL/xWBktGcnf7tgwKJGl92AbP8CVzC096v1tH9cCL
   w4d1pdHU/CSFCPyCoLY9uWOPs+84YQe4frtQwpL5C1rChziwILsZehaf3POnr9K8KrYPGlqYPZ8
   +/SawBrY5hnUIaJLGhqINZqhf9Z4NieqbXeWpMX9WDiB2QsgT6qpv4hm4NiA64omezl7NBCIUeH
   lu0rGPwASelYdQ==;
Message-Instance:  m=1;
 h=sha256:
   ulpar99XdlXLkzOVLIcxnsj7O5FOApAyqsp7tQU9cwg=:
   lui/X5FCZLmMP2GIEIHwnW68KR/7GeRe/+On88m/hT8=,
  sha512:
   yOCM/6kiT+Y7DMU1fQXA422LEz86VMkrNLcEY5wVukkbbnBvsz/57Wv7MY2Q3V6MJR+VrIyghEDH2Ld/Nug/HA==:
   OuikgOfuuxYz9vT7xTQPVyT0iQUGZMmEnJwRoJcOFzpRyqsuy+MMkruEnOu1Ho0RRcY/EWHGqVx0b+SrsCSx9w==;
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1794413967; x=1795018767;
	i=alexander.hoelzl@gmx.net;
	bh=0n/XOOfVUiXylXawprcUPz/nyE3SrDlWH2QD2dFNhgU=;
	h=X-UI-Sender-Class:From:To:Cc:Subject:Date:Message-ID:
	 MIME-Version:Content-Transfer-Encoding:cc:
	 content-transfer-encoding:content-type:date:from:message-id:
	 mime-version:reply-to:subject:to;
	b=BclIHpQwoh2rLsbu5tFu1AdIt9pjFi6zgkp4cm5IsgGXUlgMWpdEun6Ddhz/nLof
	 56gZOv6EdLlp4m8ZRiWH6bPtlw3JbhiejYdatIjhJt61DrOYwE44Bv0oDXHP9OGDn
	 fUtJeDBl8itWeEgKq9hx05tuzK9txk8lTj78SvKWQqq/xKm3PJQTsfcXtqCPEXou1
	 k9RiZbJG9JpL0+CM0ncxwJS8rN3e4VR+2gUpAcjj7Eov8RbOIWQKnWqf1kMgYDC9Y
	 i6LblI4hG1dHISwG9PjXMaUEXaNJSwIt8kczS0UoP9G4Mm+ijXDUdICheRL4AAFZS
	 Y6ldG9Tymnj6vb22JQ==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx105
 [212.227.17.168]) with ESMTPSA (Nemesis) id 1MBDnC-1xK4J71iMo-00C0xQ; Wed, 11
 Nov 2026 17:19:27 +0100
From: =?UTF-8?q?Alexander=20H=C3=B6lzl?= <alexander.hoelzl@gmx.net>
To: marcel@holtmann.org
Cc: ell@lists.linux.dev,
	=?UTF-8?q?Alexander=20H=C3=B6lzl?= <alexander.hoelzl@gmx.net>
Subject: [PATCH] dhcp6: fix incoming RAs being ignored
Date: Wed, 11 Nov 2026 17:19:25 +0100
Message-ID: <20261111161925.155585-1-alexander.hoelzl@gmx.net>
X-Mailer: git-send-email 2.53.0
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Post: <mailto:ell@lists.linux.dev>
List-Help: <mailto:ell+help@lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
List-Owner: <mailto:ell+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:WMAKFe1XYIUoUplf2FzC40rE6PlB3GwohJlPu4d0W2t0PN9Cu61
 fb/KZkFLgA+zLLKrrdxswh4PoM8cAYsBxFhAc0eb4xVpkRiCUkfL3gt9widQZvj6Kx2fVov
 wh4d8yaYX32a1r8uAVoSZcncz0CefL3zz4N7u+okqPgqlH3fWj9cf6f6di1omv9CQW25qIt
 rVai6LEbURa3ZqXOYs/Tw==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:Q3rZ2dcWPP8=;Rrv4q02hVtV+gUv0emqUJnXDyHY
 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
 Vr6a9zEHCJeGI28SpeShXBise/gtVquU

The dhcp6 code ignores the event_data pointer for incoming
RAs and instead reads stale data cached by the client.
As it is zero initalized this effectivley makes the client assume
that every RA has neither the managed nor the other flag set.

Fix this by using the event_data pointer instead of cached data.
=2D--
 ell/dhcp6.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 2022e42..0bcf8c5 100644
=2D-- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -1473,8 +1473,7 @@ static void dhcp6_client_icmp6_event(struct l_icmp6_=
client *icmp6,
 	switch (event) {
 	case L_ICMP6_CLIENT_EVENT_ROUTER_FOUND:
 	{
-		const struct l_icmp6_router *r =3D
-			l_icmp6_client_get_router(icmp6);
+		const struct l_icmp6_router *r =3D event_data;
 		bool managed =3D l_icmp6_router_get_managed(r);
 		bool other =3D l_icmp6_router_get_other(r);
=20
=2D-=20
2.53.0

