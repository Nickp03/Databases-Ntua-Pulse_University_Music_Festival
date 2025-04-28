-- DML

INSERT INTO perf_kind (kind_name) VALUES ('headline');
INSERT INTO perf_type (type_name) VALUES ('solo');
INSERT INTO artist (stage_name) VALUES ('Test Artist');
INSERT INTO band (band_name) VALUES ('Test Band');
INSERT INTO performance (perf_time, kind_id, type_id, artist_id, band_id) VALUES ('20:00:00', 1, 1, 1, 1);
INSERT INTO owner (first_name,last_name,age,phone_number) VALUES ('Alice','A',30,'123'), ('Bob','B',25,'456');

INSERT INTO review(owner_id, interpretation, sound_and_lighting, stage_presence, organization, overall_impression, performance_id) VALUES (1, 4, 5, 3, 4, 5, 1);
INSERT INTO review(owner_id, interpretation, sound_and_lighting, stage_presence, organization, overall_impression, performance_id) VALUES (2, 2, 3, 4, 2, 3, 1);
