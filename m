Received: from mx0a-003ede02.pphosted.com (mx0a-003ede02.pphosted.com [205.220.169.153])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC86928DC9
	for <ell@lists.linux.dev>; Mon, 13 May 2024 17:58:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=205.220.169.153
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715623132; cv=none; b=nyTyhY8VcALYNwln156CB2x5XFG7ZRN2uwrx/YbtCH3ubieFCVb7YjrAEgMPjU05j3+1V8HWssp/iw7YnI3PGQXLxbnsywYvUk+pE9GUVdl9nlxG8GSgJvSMOF0F7qp+eExaqNQU3h5qCfMduSpuwW1LYkwHWyPq9M9H3R2tK/w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715623132; c=relaxed/simple;
	bh=4EU/UWeuIL9xukUPQxn8N1zZR6V0DtK37Mq4Vu7gESs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=ldr2MkEIgGxWEdLwLcttyXACUpydiyq5tPfPhnneWqz7st9n/QHl2yW+GhWou+cB1pfzRQZHTsZYRNTDCdEVPv5myM4ChawQbIYyvEa43zi2tpkc+QqqZ2tilkXNxVHZR2qO4oZuMt2sG64KISa1h+k9EC4Cjg6RDNQh9U039z4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=getcruise.com; spf=pass smtp.mailfrom=getcruise.com; dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b=Om2VvPIi; dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b=HI+5qz9v; arc=none smtp.client-ip=205.220.169.153
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=getcruise.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=getcruise.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b="Om2VvPIi";
	dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b="HI+5qz9v"
Received: from pps.filterd (m0286615.ppops.net [127.0.0.1])
	by mx0b-003ede02.pphosted.com (8.18.1.2/8.18.1.2) with ESMTP id 44DCWIjt019889
	for <ell@lists.linux.dev>; Mon, 13 May 2024 10:58:43 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=getcruise.com;
	 h=from:to:cc:subject:date:message-id:in-reply-to:references
	:mime-version:content-type; s=ppemail; bh=WarDI4xGJReMyLojJJBDXi
	6zkyHQ2/i5reP14S63V70=; b=Om2VvPIiREvkCnij++awvxqjSDzehvPquo5T9l
	A6E7s6oF1oFIbLXxsPjp+BD7hjjpDWdsxIwYMLJcQZCOzKKuCr5rDFn5nX4VqaUT
	8QhktbMlgW4nmWio90SAoJ7IY7AccaHX5am8zE3bSI65Po+JnB5JDBOmo5CVLdIJ
	gHVbWLFDdIL72sa4V6UxGWxtNP5Ezog/iQ9hTqQ33CCBIqxvC/0bC026dYs4gZsx
	szcNNNWXoryNVLCVOg/BrcooSU5QVw0fX0iyjIvJCk09WzVdyqdFi4YX5rKqBS5b
	6n2vZYck2t8o8X3dEGfgczyEMaUAU2s4A7+4aY0u6r4/qtsA==
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by mx0b-003ede02.pphosted.com (PPS) with ESMTPS id 3y24vg96fk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <ell@lists.linux.dev>; Mon, 13 May 2024 10:58:43 -0700 (PDT)
Received: by mail-pg1-f197.google.com with SMTP id 41be03b00d2f7-61b7d7c292aso4557539a12.1
        for <ell@lists.linux.dev>; Mon, 13 May 2024 10:58:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=getcruise.com; s=google; t=1715623122; x=1716227922; darn=lists.linux.dev;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:from:to:cc:subject:date:message-id:reply-to;
        bh=WarDI4xGJReMyLojJJBDXi6zkyHQ2/i5reP14S63V70=;
        b=HI+5qz9vFGTqiEYDV/xP7Om6xIVC0OSU93GNjFuy1hbO67qnbe+5WF2y3nOei8XmgK
         S9tVa37eJJTvbUiqIqwh1aCg57PY0b5nTgisYgjo4Zz9g6yXRqxElF0iHpym2kuFIs08
         kTiSydH5K6LnEgsDBD7qG3qdpfpcd+2sBtj/a2ye5rZEJFvCvgEqcyQ7Vpu7hT9mu7/R
         jNNAlA/C5SpRWBbEemw47b4zL0lYx13eZsAqOc5U9ZyNmnh8LnXu1FGax09GKAPeXzf5
         svo+NomFJQLxURvqva66PETIqmKaY4DH0/lR+quycmdwVXVlkymcsqHUprIK085fH72b
         Liog==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1715623122; x=1716227922;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=WarDI4xGJReMyLojJJBDXi6zkyHQ2/i5reP14S63V70=;
        b=UZWEhWXpfFkQuJ/WXnZciEJXdPbPF485OYMLyaBGL57jSjI/FdgMGsI825zTCo8AY+
         7lCVgZPAVc/MSkLli3X5hvlRoca1Vb4AVq0pnXXSOqdXDbjrJyEyD5yikaQdeefljQ1h
         90i+DKeq+DBnnTIUAAsQ9aXc84N8ZBzCeyul4Z0As12K0bX683tHVCnU9Q5NEabPuBb1
         LdPjuRmKDGEj/MiXwo6i/xQUhzoWKrS28AS0r6rnlmMInBrGe0EYpc6IvHt63SG6VkQu
         x6JPvOVAq8bY2c9GJNHglYo2ArVha5xrXk/lCov99pdBUdM1sR8CWQG1QDOZazeKyjZL
         wrwg==
X-Gm-Message-State: AOJu0YwPzkBG9jf50DHf2lXaA7JhMtSbM4PF+dL+rVtR+75WXvFIvjxo
	UqogDghQy8xL9/RiyWB44GqzGxFNPvpvBkew29CJC7CGKOExuKSFCaGMZEYV4RmB8MjGbVkyKRd
	5pF4KsFuAWNe2KYKPAr4/m/bWkWUR+aGwJs8FyH2pv8ECpMQsis+Ntxg15qS3WitzUTxZLkSxFo
	3ZuDhubIac+MAnq08++Sz4fYXcIrli2rDTv5c9MRzF5bjFU+g=
X-Received: by 2002:a05:6a21:19c:b0:1af:a2fa:e666 with SMTP id adf61e73a8af0-1afde0b6e9emr11237074637.10.1715623122357;
        Mon, 13 May 2024 10:58:42 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IF/9sTbrpFQTA3jGqJH7h93xV5ZXOAuiV2ICAO+mAOZmj8yxSQrwtxa+3CSsudERDBpMtJ5Ww==
X-Received: by 2002:a05:6a21:19c:b0:1af:a2fa:e666 with SMTP id adf61e73a8af0-1afde0b6e9emr11237047637.10.1715623121890;
        Mon, 13 May 2024 10:58:41 -0700 (PDT)
Received: from BPHKDV2-DT.corp.robot.car ([199.73.127.2])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-6340b76e262sm7031567a12.35.2024.05.13.10.58.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 13 May 2024 10:58:41 -0700 (PDT)
From: Ram Subramanian <ram.subramanian@getcruise.com>
To: ell@lists.linux.dev
Cc: Ram Subramanian <ram.subramanian@getcruise.com>,
        Ramon Ribeiro <rhpr@cesar.org.br>
Subject: [PATCH 2/2] unit: add testing for dbus-over-tcp
Date: Mon, 13 May 2024 10:58:26 -0700
Message-ID: <20240513175826.2363352-2-ram.subramanian@getcruise.com>
X-Mailer: git-send-email 2.43.2
In-Reply-To: <20240513175826.2363352-1-ram.subramanian@getcruise.com>
References: <20240513175826.2363352-1-ram.subramanian@getcruise.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
X-Proofpoint-ORIG-GUID: F7CAijAfQFX7Y4esqcigVIrXkz5EoclM
X-Proofpoint-GUID: F7CAijAfQFX7Y4esqcigVIrXkz5EoclM
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1039,Hydra:6.0.650,FMLib:17.11.176.26
 definitions=2024-05-13_12,2024-05-10_02,2023-05-22_02
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 adultscore=0 mlxlogscore=999
 impostorscore=0 suspectscore=0 spamscore=0 phishscore=0 bulkscore=0
 priorityscore=1501 clxscore=1015 lowpriorityscore=0 mlxscore=0
 malwarescore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.19.0-2405010000 definitions=main-2405130120

Co-authored-by: Ramon Ribeiro <rhpr@cesar.org.br>
---
 unit/dbus.conf   |   2 +
 unit/test-dbus.c | 118 +++++++++++++++++++++++++++++++++--------------
 2 files changed, 85 insertions(+), 35 deletions(-)

diff --git a/unit/dbus.conf b/unit/dbus.conf
index 97e1bb5..5fe41a9 100644
--- a/unit/dbus.conf
+++ b/unit/dbus.conf
@@ -7,6 +7,8 @@
   <allow_anonymous />
 
   <listen>unix:path=/tmp/ell-test-bus</listen>
+  <listen>tcp:host=localhost,bind=*,port=14046,family=ipv4</listen>
+  <apparmor mode="disabled" />
 
   <policy context="default">
     <!-- Allow everything to be sent -->
diff --git a/unit/test-dbus.c b/unit/test-dbus.c
index 5b98385..9006d0e 100644
--- a/unit/test-dbus.c
+++ b/unit/test-dbus.c
@@ -20,11 +20,17 @@
 #define WAIT_ANY (-1) /* Any process */
 #endif
 
-#define TEST_BUS_ADDRESS "unix:path=/tmp/ell-test-bus"
+#define TEST_BUS_ADDRESS_UNIX "unix:path=/tmp/ell-test-bus"
+#define TEST_BUS_ADDRESS_TCP "tcp:host=127.0.0.1,port=14046"
 
 static pid_t dbus_daemon_pid = -1;
 
-static void start_dbus_daemon(void)
+static int tests_completed = 0;
+static bool bus_became_ready = false;
+static bool match_cb_called = false;
+static bool req_name_cb_called = false;
+
+static bool start_dbus_daemon(void)
 {
 	char *prg_argv[5];
 	char *prg_envp[1];
@@ -43,7 +49,7 @@ static void start_dbus_daemon(void)
 	pid = fork();
 	if (pid < 0) {
 		l_error("failed to fork new process");
-		return;
+		return false;
 	}
 
 	if (pid == 0) {
@@ -54,6 +60,8 @@ static void start_dbus_daemon(void)
 	l_info("dbus-daemon process %d created", pid);
 
 	dbus_daemon_pid = pid;
+
+	return true;
 }
 
 static void signal_handler(uint32_t signo, void *user_data)
@@ -93,6 +101,17 @@ static void do_debug(const char *str, void *user_data)
 	l_info("%s%s", prefix, str);
 }
 
+#define test_assert(cond)	\
+	do {	\
+		if (!(cond)) {	\
+			l_info("TEST FAILED in %s at %s:%i: %s",	\
+				__func__, __FILE__, __LINE__,	\
+				L_STRINGIFY(cond));	\
+			l_main_quit();	\
+			return;	\
+		}	\
+	} while (0)
+
 static void signal_message(struct l_dbus_message *message, void *user_data)
 {
 	const char *path, *interface, *member, *destination, *sender;
@@ -135,18 +154,19 @@ static void request_name_callback(struct l_dbus_message *message,
 	const char *error, *text;
 	uint32_t result;
 
+	req_name_cb_called = true;
+
 	if (l_dbus_message_get_error(message, &error, &text)) {
 		l_error("error=%s", error);
 		l_error("message=%s", text);
-		goto done;
+		test_assert(false);
 	}
 
-	if (!l_dbus_message_get_arguments(message, "u", &result))
-		goto done;
+	test_assert(l_dbus_message_get_arguments(message, "u", &result));
 
 	l_info("request name result=%d", result);
 
-done:
+	tests_completed ++;
 	l_main_quit();
 }
 
@@ -161,21 +181,41 @@ static void add_match_callback(struct l_dbus_message *message, void *user_data)
 {
 	const char *error, *text;
 
+	match_cb_called = true;
+
 	if (l_dbus_message_get_error(message, &error, &text)) {
 		l_error("error=%s", error);
 		l_error("message=%s", text);
+		test_assert(false);
 		return;
 	}
 
-	if (!l_dbus_message_get_arguments(message, ""))
-		return;
+	test_assert(l_dbus_message_get_arguments(message, ""));
 
 	l_info("add match");
 }
 
 static void ready_callback(void *user_data)
 {
+	struct l_dbus *dbus = user_data;
+	int rc;
+
 	l_info("ready");
+	bus_became_ready = true;
+
+	rc = l_dbus_method_call(dbus, "org.freedesktop.DBus",
+				"/org/freedesktop/DBus",
+				"org.freedesktop.DBus", "AddMatch",
+				add_match_setup,
+				add_match_callback, NULL, NULL);
+	test_assert(rc > 0);
+
+	rc = l_dbus_method_call(dbus, "org.freedesktop.DBus",
+				"/org/freedesktop/DBus",
+				"org.freedesktop.DBus", "RequestName",
+				request_name_setup,
+				request_name_callback, NULL, NULL);
+	test_assert(rc > 0);
 }
 
 static void disconnect_callback(void *user_data)
@@ -183,31 +223,29 @@ static void disconnect_callback(void *user_data)
 	l_main_quit();
 }
 
-int main(int argc, char *argv[])
+static void test_dbus(const void *data)
 {
+	const char *address = data;
 	struct l_dbus *dbus;
-	struct l_signal *sigchld;
 	int i;
 
-	if (!l_main_init())
-		return -1;
+	bus_became_ready = false;
+	match_cb_called = false;
+	req_name_cb_called = false;
+
+	test_assert(l_main_init());
 
 	l_log_set_stderr();
 
-	start_dbus_daemon();
-
 	for (i = 0; i < 10; i++) {
 		usleep(200 * 1000);
 
-		dbus = l_dbus_new(TEST_BUS_ADDRESS);
+		dbus = l_dbus_new(address);
 		if (dbus)
 			break;
 	}
 
-	sigchld = l_signal_create(SIGCHLD, sigchld_handler, NULL, NULL);
-
-	if (!dbus)
-		goto done;
+	test_assert(dbus);
 
 	l_dbus_set_debug(dbus, do_debug, "[DBUS] ", NULL);
 
@@ -216,29 +254,39 @@ int main(int argc, char *argv[])
 
 	l_dbus_register(dbus, signal_message, NULL, NULL);
 
-	l_dbus_method_call(dbus, "org.freedesktop.DBus",
-				"/org/freedesktop/DBus",
-				"org.freedesktop.DBus", "AddMatch",
-				add_match_setup,
-				add_match_callback, NULL, NULL);
-
-	l_dbus_method_call(dbus, "org.freedesktop.DBus",
-				"/org/freedesktop/DBus",
-				"org.freedesktop.DBus", "RequestName",
-				request_name_setup,
-				request_name_callback, NULL, NULL);
-
 	l_main_run_with_signal(signal_handler, NULL);
 
+	test_assert(bus_became_ready);
+	test_assert(match_cb_called);
+	test_assert(req_name_cb_called);
+
 	l_dbus_destroy(dbus);
+	l_main_exit();
+}
+
+int main(int argc, char *argv[])
+{
+	struct l_signal *sigchld;
+
+	l_test_init(&argc, &argv);
+
+	l_test_add("Using a unix socket", test_dbus, TEST_BUS_ADDRESS_UNIX);
+	l_test_add("Using a tcp socket", test_dbus, TEST_BUS_ADDRESS_TCP);
+
+	sigchld = l_signal_create(SIGCHLD, sigchld_handler, NULL, NULL);
+
+	if (!start_dbus_daemon())
+		return -1;
+
+	l_test_run();
 
-done:
 	if (dbus_daemon_pid > 0)
 		kill(dbus_daemon_pid, SIGKILL);
 
 	l_signal_remove(sigchld);
 
-	l_main_exit();
+	if (tests_completed == 2)
+		return 0;
 
-	return 0;
+	return -1;
 }
-- 
2.43.2


-- 


*Confidentiality Note:* We care about protecting our proprietary 
information, confidential material, and trade secrets. This message may 
contain some or all of those things. Cruise will suffer material harm if 
anyone other than the intended recipient disseminates or takes any action 
based on this message. If you have received this message (including any 
attachments) in error, please delete it immediately and notify the sender 
promptly.
