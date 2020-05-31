INSERT INTO requirements (name, icon) VALUES ('10 x Sauldia Ruby', 'icons/traits/truthofoceans.png');
INSERT INTO requirements (name, icon) VALUES ('10 x Noblefish', 'icons/traits/truthofoceans.png');
INSERT INTO requirements (name, icon) VALUES ('10 x Glaring Perch', 'icons/traits/truthofoceans.png');
INSERT INTO requirements (name, icon) VALUES ('7 x Mercenary Crab', 'icons/traits/truthofoceans.png');
INSERT INTO requirements (name, icon) VALUES ('10 x Treescale', 'icons/traits/truthofoceans.png');
INSERT INTO requirements (name, icon) VALUES ('7 x Bashful Batfish', 'icons/traits/truthofoceans.png');
INSERT INTO requirements (name, icon) VALUES ('10 x Ichimonji', 'icons/traits/truthofoceans.png');
INSERT INTO requirements (name, icon) VALUES ('10 x Ichthyosaur', 'icons/traits/truthofoceans.png');

UPDATE nodes SET cbhid=90491, requires='7 x Mercenary Crab' WHERE name='Swimming Shadows (Mercenary Crab)';
DELETE FROM cbh_node_tables WHERE nodegid=877;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (877, 'aaaaaaaaaaa', '0748d28ca97', 21) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (877, 'aaaaaaaaaaa', '0a49d9e50e5', 22) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (877, 'aaaaaaaaaab', '98df4baac14', 28) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (877, 'aaaaaaaaaab', '69471ccde83', 30) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (877, 'aaaaaaaaaac', '93372621868', 157) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (877, 'aaaaaaaaaac', '789bfbc3e94', 139) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;

UPDATE nodes SET cbhid=100191, requires='7 x Bashful Batfish' WHERE name='Swimming Shadows (Bashful Batfish)';
DELETE FROM cbh_node_tables WHERE nodegid=871;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (871, 'aaaaaaaaaaa', '1785e71d213', 1007) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (871, 'aaaaaaaaaaa', '8c862b34c66', 914) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (871, 'aaaaaaaaaaa', '59cf4205888', 65) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (871, 'aaaaaaaaaab', '4a45c631069', 2759) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (871, 'aaaaaaaaaab', 'fe7c388627a', 1427) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (871, 'aaaaaaaaaab', '59cf4205888', 132) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (871, 'aaaaaaaaaac', 'b6a7c2f1fee', 7141) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (871, 'aaaaaaaaaac', 'cd7a8ac824b', 9361) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (871, 'aaaaaaaaaac', '59cf4205888', 526) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;

UPDATE nodes SET cbhid=100192, requires='10 x Ichimonji' WHERE name='Swimming Shadows (Ichimonji)';
DELETE FROM cbh_node_tables WHERE nodegid=870;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (870, 'aaaaaaaaaaa', '6d31dec1dc6', 58) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (870, 'aaaaaaaaaaa', '1785e71d213', 53) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (870, 'aaaaaaaaaab', 'fe7c388627a', 1072) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (870, 'aaaaaaaaaab', '46a431b7497', 4017) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (870, 'aaaaaaaaaac', 'f0d15a63022', 203) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (870, 'aaaaaaaaaac', '84de0dd07e0', 353) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;

UPDATE nodes SET cbhid=100291, requires='10 x Ichthyosaur' WHERE name='Swimming Shadows (Ichthyosaur)';
DELETE FROM cbh_node_tables WHERE nodegid=872;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (872, 'aaaaaaaaaaa', 'ee0defbf946', 112) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (872, 'aaaaaaaaaaa', '7c00a326d71', 134) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (872, 'aaaaaaaaaab', 'f1d10478718', 1471) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (872, 'aaaaaaaaaab', '052e12536ce', 892) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (872, 'aaaaaaaaaac', '5642db12cc6', 355) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (872, 'aaaaaaaaaac', 'a167f25cbaf', 339) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;

UPDATE nodes SET cbhid=100391, requires='10 x Glaring Perch' WHERE name='Swimming Shadows (Glaring Perch)';
DELETE FROM cbh_node_tables WHERE nodegid=873;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (873, 'aaaaaaaaaaa', '7b3a7480eeb', 1035) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (873, 'aaaaaaaaaaa', '9b940b5cda8', 1108) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (873, 'aaaaaaaaaab', '9cec0de8cfc', 53) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (873, 'aaaaaaaaaab', 'd25e36dcdf5', 56) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (873, 'aaaaaaaaaac', '060a2c8a56a', 106) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (873, 'aaaaaaaaaac', '2e4de481384', 208) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;

UPDATE nodes SET cbhid=120391, requires='10 x Noblefish' WHERE name='Swimming Shadows (Noblefish)';
DELETE FROM cbh_node_tables WHERE nodegid=874;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (874, 'aaaaaaaaaaa', 'ec20540f2d1', 251) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (874, 'aaaaaaaaaaa', '4462e25f290', 106) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (874, 'aaaaaaaaaab', '0120933af48', 107) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (874, 'aaaaaaaaaab', '2fe67c7bca6', 118) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (874, 'aaaaaaaaaac', '40ae818e191', 509) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (874, 'aaaaaaaaaac', 'a7aa4fa56f0', 465) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;

UPDATE nodes SET cbhid=120691, requires='10 x Sauldia Ruby' WHERE name='Swimming Shadows (Sauldia Ruby)';
DELETE FROM cbh_node_tables WHERE nodegid=875;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (875, 'aaaaaaaaaaa', '54704279075', 11) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (875, 'aaaaaaaaaaa', '3d6b61b8e02', 19) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (875, 'aaaaaaaaaab', '209427fab06', 508) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (875, 'aaaaaaaaaab', 'd361d7fffef', 344) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (875, 'aaaaaaaaaac', 'd0be0d76a7a', 30) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (875, 'aaaaaaaaaac', 'e75876fc2ff', 25) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;

UPDATE nodes SET cbhid=120791, requires='10 x Treescale' WHERE name='Swimming Shadows (Treescale)';
DELETE FROM cbh_node_tables WHERE nodegid=876;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (876, 'aaaaaaaaaaa', '3fadf06b7f3', 410) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (876, 'aaaaaaaaaaa', 'b39cbb04ab7', 350) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (876, 'aaaaaaaaaab', '6e1dc320537', 2) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (876, 'aaaaaaaaaab', '41ca03e9706', 11) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (876, 'aaaaaaaaaac', '27e531311f8', 40) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;
INSERT INTO cbh_node_tables (nodegid, baitlid, fishlid, catches) VALUES (876, 'aaaaaaaaaac', '8a29ce42dca', 24) ON CONFLICT ON CONSTRAINT cbh_node_tables_pkey DO UPDATE SET catches=EXCLUDED.catches;