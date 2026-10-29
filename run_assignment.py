"""SQL 파일을 실행하고 results/에 실제 결과를 기록합니다 (외부 패키지 불필요)."""

from pathlib import Path
import re
import sqlite3


ROOT = Path(__file__).resolve().parent


def run_statements(connection, source):
    """한 문장씩 실행하여 SELECT 결과와 수정·삭제 건수를 함께 남깁니다."""
    output = []
    statement = ""
    for line in source.splitlines():
        statement += line + "\n"
        if not sqlite3.complete_statement(statement):
            continue
        cursor = connection.execute(statement)
        output.append(statement.strip())
        if cursor.description:
            output.append(" | ".join(column[0] for column in cursor.description))
            rows = cursor.fetchall()
            for row in rows:
                output.append(" | ".join("NULL" if v is None else str(v) for v in row))
            output.append(f"결과: {len(rows)}행")
        elif cursor.rowcount >= 0:
            output.append(f"변경: {cursor.rowcount}행")
        else:
            output.append("실행 완료")
        output.append("")
        statement = ""
    return "\n".join(output)


def main():
    results = ROOT / "results"
    results.mkdir(exist_ok=True)
    # 실행할 때마다 메모리에서 새로 만들기 때문에 기존 DB를 덮어쓰지 않습니다.
    with sqlite3.connect(":memory:", isolation_level=None) as connection:
        connection.executescript((ROOT / "schema.sql").read_text(encoding="utf-8"))
        connection.executescript((ROOT / "seed.sql").read_text(encoding="utf-8"))
        source = (ROOT / "queries.sql").read_text(encoding="utf-8")
        sections = re.split(r"(?=^-- Q\d{2} \|)", source, flags=re.MULTILINE)
        connection.executescript(sections[0])
        for section in sections[1:]:
            number = re.match(r"-- (Q\d{2})", section).group(1)
            (results / f"{number}.txt").write_text(
                run_statements(connection, section), encoding="utf-8"
            )

        checks = [f"SQLite 버전: {sqlite3.sqlite_version}"]
        for table, expected in [("cuisine", 10), ("recipe", 20), ("member", 10), ("review", 20)]:
            count = connection.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
            assert count == expected, (table, count)
            checks.append(f"{table}: {count}행 (확인 완료)")
        assert connection.execute("PRAGMA foreign_keys").fetchone()[0] == 1
        assert connection.execute("PRAGMA foreign_key_check").fetchall() == []
        assert connection.execute("PRAGMA integrity_check").fetchone()[0] == "ok"
        assert connection.execute("SELECT cooking_minutes FROM recipe WHERE recipe_id = 1").fetchone()[0] == 15
        checks.append("외래 키 활성화, 무결성, 수정·삭제 복구: 확인 완료")

        # 실패해야 정상인 입력을 각각 시도합니다. 실패한 문장은 저장되지 않습니다.
        invalid_inputs = [
            ("없는 요리 참조", "INSERT INTO review VALUES (99, 999, 1, 5, 'FK 실습')"),
            ("닉네임 중복", "INSERT INTO member VALUES (99, '밥사랑')"),
            ("필수 이름 누락", "INSERT INTO cuisine VALUES (99, NULL)"),
            ("평점 범위 위반", "INSERT INTO review VALUES (99, 20, 1, 6, '평점 실습')"),
        ]
        for label, sql in invalid_inputs:
            try:
                connection.execute(sql)
            except sqlite3.IntegrityError as error:
                checks.append(f"{label}: 예상대로 거부됨 ({error})")
            else:
                raise AssertionError(f"제약조건 확인 실패: {label}")
        (results / "validation.txt").write_text("\n".join(checks) + "\n", encoding="utf-8")
    print("완료: results/Q01.txt ~ Q15.txt, validation.txt")


if __name__ == "__main__":
    main()
