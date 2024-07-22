Received: from mail-oo1-f53.google.com (mail-oo1-f53.google.com [209.85.161.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F98A16EB6E
	for <ell@lists.linux.dev>; Mon, 22 Jul 2024 19:04:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721675091; cv=none; b=semeozHRMbkp1LUGu2c147COdulZNdRRUy6Wd/0NcUZklFTRmAvSXbNPV8H2SYwIZSSa/g30qC33SRH/VeGneNEI5evL2MEIUgWTS2OmSH4gITVxOMQ/DkKEM4yYdDUiKSu0fkAEokr4k0ZYoEyzTmY008uXz0UxyN++f3f/l30=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721675091; c=relaxed/simple;
	bh=zoACB15UJymFC/3yTgf9oeIzU3HaO3afBeov9YD7y3w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=owG6LqkuyWTgkT+zbL0HmmlwnYyWL1QO3+5GevAcPszGN4HagFleCKAOUJAbbDK/qjXXv9zwTrE0F1eD9eji1NdjquG3i2VBalrQ08ag7I5LziLn+ZD3ymAH1EDvl5xBJBgqm+N4LnlHZMmNGBxLos3l/CCgQWKkIWfV+KhQIDI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=AH7EAN96; arc=none smtp.client-ip=209.85.161.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AH7EAN96"
Received: by mail-oo1-f53.google.com with SMTP id 006d021491bc7-5d4fb707895so2549339eaf.0
        for <ell@lists.linux.dev>; Mon, 22 Jul 2024 12:04:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721675089; x=1722279889; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=jiRv008JRANyR7s7yqGbHvOaQRAx716GauA0f+wPekI=;
        b=AH7EAN96J0JtQozEa9KWDd6l1d08on/PnEGoX97BWRcoFWJHfTtImLqTGtBLfpIZch
         dAQX6Lbtk6O1cBNQvUF6gDOH56sS+fgXd07AjcBJDMYv6YoYIMxzzzSCUCva7CVDw6OV
         TbLVIwKG535BWn+1VXLIPDq7XOyGDTmmuugXNj/zqCOSP8QMXi9y0AjTzuk0mmgt8+UO
         SHkFMnE2JRts5xY0K+tyo9As+DtK4NXuuy5dDcHLsRw3U0RiUBxuieF5j5dqHEdBCjsa
         TLfIvpU4m1xag/dARER+csVL2MI6jyiFzlDAn6DgL7CYHOvL/Wxc5vr+CD1CCPJ23eHZ
         YXWQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721675089; x=1722279889;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=jiRv008JRANyR7s7yqGbHvOaQRAx716GauA0f+wPekI=;
        b=XhxNqPa+6/BLQrr8gpNhwF5fMHjkPRFthVzgP0f371xeYRvARqDQXzNlj/owGTLRJm
         gMoTcb/hwy3pyO98J837GIdY9IMmXKxbaUFJ/qWiZkGBWKmCxjRlY+hc+UNzSZeI5em/
         aHcS60AB5DgvnIovJT2agXi+V/NVZA61k3tpFeGUdG5uAlTguBeKPN2PkwKpyEoT3Lyi
         wS01YMpH1aqBQv/vKrn09it9TANVmaiNN3ZwmohilGQePyucsMO5LjnvVThsieQTSBgH
         ID4AXBG2MAPJbXcstApSw9Egj/KbjyK5XCHwIKcq18598CxPQcYon67pUpBspMJ6DZyp
         PkNQ==
X-Gm-Message-State: AOJu0YxAN/HZqRqjOQyggS1UvR1VqCdBH7mlLksUPAQOUiRSE2/hil8L
	ANr+d5ocK2F52CzU3djZLVg02q8MmaYYYOer7+UGrgiYzUY6DM6tedi3Rg==
X-Google-Smtp-Source: AGHT+IHVdBccHKfqB4JZfvOd1UeCVORIJhILU6ARhbO5ZQ+7ImTm22gj25Bd1BMtevvUJ11DuNkwSg==
X-Received: by 2002:a05:6820:c8b:b0:5c4:144b:1ff9 with SMTP id 006d021491bc7-5d564faa2ddmr10906446eaf.5.1721675089134;
        Mon, 22 Jul 2024 12:04:49 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5d55aaee1fasm1411186eaf.42.2024.07.22.12.04.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Jul 2024 12:04:48 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 05/12] unit: Refactor genl-msg tests
Date: Mon, 22 Jul 2024 14:04:22 -0500
Message-ID: <20240722190443.43196-5-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20240722190443.43196-1-denkenz@gmail.com>
References: <20240722190443.43196-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Both parse|build_set_station and parse|build_set_rekey_offload tests
declare precanned information as static const variables in the
individual test functions.  Declare this precanned information inside a
test structure for easier maintenance and future reusability.
---
 unit/test-genl-msg.c | 124 ++++++++++++++++++++++++++-----------------
 1 file changed, 74 insertions(+), 50 deletions(-)

diff --git a/unit/test-genl-msg.c b/unit/test-genl-msg.c
index 0ae92aefebc9..e6432f4362ef 100644
--- a/unit/test-genl-msg.c
+++ b/unit/test-genl-msg.c
@@ -31,10 +31,25 @@ static unsigned char set_station_request[] = {
 	0x02, 0x00, 0x00, 0x00,
 };
 
+struct set_station_test {
+	uint8_t mac[6];
+	uint32_t ifindex;
+	uint32_t flags[2];
+	uint32_t seq;
+	uint32_t pid;
+};
+
+static const struct set_station_test set_station = {
+	.mac = { 0x24, 0xa2, 0xe1, 0xec, 0x17, 0x04 },
+	.ifindex = 3,
+	.flags = { 2, 2 },
+	.seq = 0x550d538b,
+	.pid = 3604,
+};
+
 static void parse_set_station(const void *data)
 {
-	static const unsigned char mac[6] =
-		{ 0x24, 0xa2, 0xe1, 0xec, 0x17, 0x04 };
+	const struct set_station_test *test = data;
 	struct nlmsghdr *nlmsg;
 	struct l_genl_msg *msg;
 	struct l_genl_attr attr;
@@ -56,13 +71,13 @@ static void parse_set_station(const void *data)
 	assert(l_genl_attr_next(&attr, &type, &len, &payload));
 	assert(type == 3);
 	assert(len == 4);
-	assert(*((unsigned int *) payload) == 3);
+	assert(*((unsigned int *) payload) == test->ifindex);
 
 	/* MAC Address 24:A2:E1:EC:17:04 */
 	assert(l_genl_attr_next(&attr, &type, &len, &payload));
 	assert(type == 6);
-	assert(len == 6);
-	assert(!memcmp(payload, mac, 6));
+	assert(len == sizeof(test->mac));
+	assert(!memcmp(payload, test->mac, sizeof(test->mac)));
 
 	/* Station Flags 2: len 8
 	 *     Mask: 0x00000002
@@ -72,19 +87,16 @@ static void parse_set_station(const void *data)
 	 */
 	assert(l_genl_attr_next(&attr, &type, &len, &payload));
 	assert(type == 67);
-	assert(len == 8);
-	assert(((unsigned int *) payload)[0] == 2);
-	assert(((unsigned int *) payload)[1] == 2);
+	assert(len == sizeof(test->flags));
+	assert(((unsigned int *) payload)[0] == test->flags[0]);
+	assert(((unsigned int *) payload)[1] == test->flags[1]);
 
 	l_genl_msg_unref(msg);
 }
 
 static void build_set_station(const void *data)
 {
-	static uint32_t index = 3;
-	static const unsigned char mac[6] =
-		{ 0x24, 0xa2, 0xe1, 0xec, 0x17, 0x04 };
-	static uint32_t flags[] = { 2, 2 };
+	const struct set_station_test *test = data;
 	struct l_genl_msg *msg;
 	const void *raw;
 	size_t size;
@@ -92,15 +104,19 @@ static void build_set_station(const void *data)
 	msg = l_genl_msg_new_sized(18, 512);
 	assert(msg);
 
-	assert(l_genl_msg_append_attr(msg, 3, 4, &index));
-	assert(l_genl_msg_append_attr(msg, 6, 6, mac));
-	assert(l_genl_msg_append_attr(msg, 67, 8, flags));
+	assert(l_genl_msg_append_attr(msg, 3,
+					sizeof(test->ifindex), &test->ifindex));
+	assert(l_genl_msg_append_attr(msg, 6, sizeof(test->mac), test->mac));
+	assert(l_genl_msg_append_attr(msg, 67,
+					sizeof(test->flags), test->flags));
 
-	raw = l_genl_msg_to_data(msg, 0x17, 0x05, 0x550d538b, 3604, &size);
+	raw = l_genl_msg_to_data(msg, 0x17, NLM_F_REQUEST | NLM_F_ACK,
+					test->seq, test->pid, &size);
 
 	if (do_print) {
 		l_util_hexdump(false, raw, size, do_debug, "[MSG] ");
-		l_util_hexdump(true, set_station_request, size,
+		l_util_hexdump(true, set_station_request,
+					sizeof(set_station_request),
 					do_debug, "[MSG] ");
 	}
 
@@ -120,16 +136,29 @@ static const unsigned char set_rekey_offload_request[] = {
 	0x0c, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
 };
 
+struct set_rekey_offload_test {
+	uint32_t seq;
+	uint32_t pid;
+	uint32_t ifindex;
+	uint8_t kek[16];
+	uint8_t kck[16];
+	uint8_t replay_counter[8];
+};
+
+static const struct set_rekey_offload_test rekey_offload = {
+	.seq = 0x53e1a359,
+	.pid = 0xe74002ba,
+	.kek = {	0x2f, 0x82, 0xbb, 0x0d, 0x93, 0x56, 0x60, 0x4b,
+			0xb1, 0x55, 0x1c, 0x85, 0xc0, 0xeb, 0x32, 0x8b },
+	.kck = {	0x43, 0x25, 0xcf, 0x08, 0x0b, 0x92, 0xa7, 0x2d,
+			0x86, 0xdc, 0x43, 0x21, 0xd6, 0x0c, 0x12, 0x03 },
+	.replay_counter = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01 },
+	.ifindex = 3,
+};
+
 static void parse_set_rekey_offload(const void *data)
 {
-	static const unsigned char kek[] = {
-		0x2f, 0x82, 0xbb, 0x0d, 0x93, 0x56, 0x60, 0x4b,
-		0xb1, 0x55, 0x1c, 0x85, 0xc0, 0xeb, 0x32, 0x8b };
-	static const unsigned char kck[] = {
-		0x43, 0x25, 0xcf, 0x08, 0x0b, 0x92, 0xa7, 0x2d,
-		0x86, 0xdc, 0x43, 0x21, 0xd6, 0x0c, 0x12, 0x03 };
-	static const unsigned char replay_counter[] = {
-		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01 };
+	const struct set_rekey_offload_test *test = data;
 	struct nlmsghdr *nlmsg;
 	struct l_genl_msg *msg;
 	struct l_genl_attr attr;
@@ -172,33 +201,25 @@ static void parse_set_rekey_offload(const void *data)
 
 	assert(l_genl_attr_next(&nested, &type, &len, &payload));
 	assert(type == 1);
-	assert(len == 16);
-	assert(!memcmp(payload, kek, 16));
+	assert(len == sizeof(test->kek));
+	assert(!memcmp(payload, test->kek, sizeof(test->kek)));
 
 	assert(l_genl_attr_next(&nested, &type, &len, &payload));
 	assert(type == 2);
-	assert(len == 16);
-	assert(!memcmp(payload, kck, 16));
+	assert(len == sizeof(test->kck));
+	assert(!memcmp(payload, test->kck, sizeof(test->kck)));
 
 	assert(l_genl_attr_next(&nested, &type, &len, &payload));
 	assert(type == 3);
-	assert(len == 8);
-	assert(!memcmp(payload, replay_counter, 8));
+	assert(len == sizeof(test->replay_counter));
+	assert(!memcmp(payload, test->replay_counter, len));
 
 	l_genl_msg_unref(msg);
 }
 
 static void build_set_rekey_offload(const void *data)
 {
-	static uint32_t index = 3;
-	static const unsigned char kek[] = {
-		0x2f, 0x82, 0xbb, 0x0d, 0x93, 0x56, 0x60, 0x4b,
-		0xb1, 0x55, 0x1c, 0x85, 0xc0, 0xeb, 0x32, 0x8b };
-	static const unsigned char kck[] = {
-		0x43, 0x25, 0xcf, 0x08, 0x0b, 0x92, 0xa7, 0x2d,
-		0x86, 0xdc, 0x43, 0x21, 0xd6, 0x0c, 0x12, 0x03 };
-	static const unsigned char replay_counter[] = {
-		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01 };
+	const struct set_rekey_offload_test *test = data;
 	struct l_genl_msg *msg;
 	const void *raw;
 	size_t size;
@@ -206,16 +227,19 @@ static void build_set_rekey_offload(const void *data)
 	msg = l_genl_msg_new_sized(79, 0);
 	assert(msg);
 
-	assert(l_genl_msg_append_attr(msg, 3, 4, &index));
+	assert(l_genl_msg_append_attr(msg, 3,
+					sizeof(test->ifindex), &test->ifindex));
 
 	assert(l_genl_msg_enter_nested(msg, 122));
-	assert(l_genl_msg_append_attr(msg, 1, 16, kek));
-	assert(l_genl_msg_append_attr(msg, 2, 16, kck));
-	assert(l_genl_msg_append_attr(msg, 3, 8, replay_counter));
+	assert(l_genl_msg_append_attr(msg, 1, sizeof(test->kek), test->kek));
+	assert(l_genl_msg_append_attr(msg, 2, sizeof(test->kck), test->kck));
+	assert(l_genl_msg_append_attr(msg, 3, sizeof(test->replay_counter),
+						test->replay_counter));
 	assert(l_genl_msg_leave_nested(msg));
 
-	raw = l_genl_msg_to_data(msg, 0x1b, 0x05, 0x53e1a359, 0xe74002ba,
-					&size);
+	raw = l_genl_msg_to_data(msg, 0x1b, NLM_F_REQUEST | NLM_F_ACK,
+					test->seq, test->pid, &size);
+
 	if (do_print) {
 		l_util_hexdump(false, raw, size, do_debug, "[MSG] ");
 		l_util_hexdump(true, set_rekey_offload_request, size,
@@ -412,13 +436,13 @@ int main(int argc, char *argv[])
 	if (!little_endian)
 		goto done;
 
-	l_test_add("Parse Set Station Request", parse_set_station, NULL);
+	l_test_add("Parse Set Station Request", parse_set_station, &set_station);
 	l_test_add("Parse Set Rekey Offload Request",
-				parse_set_rekey_offload, NULL);
+				parse_set_rekey_offload, &rekey_offload);
 
-	l_test_add("Build Set Station Request", build_set_station, NULL);
+	l_test_add("Build Set Station Request", build_set_station, &set_station);
 	l_test_add("Build Set Rekey Offload Request",
-				build_set_rekey_offload, NULL);
+				build_set_rekey_offload, &rekey_offload);
 
 	l_test_add("libnl-generated Example with Nesting",
 				parse_libnl_nested, NULL);
-- 
2.45.2

