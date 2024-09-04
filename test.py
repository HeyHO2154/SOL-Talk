import os
from datetime import datetime

# 바탕화면 경로 설정
desktop_path = os.path.join(os.path.join(os.environ['USERPROFILE']), 'Desktop')

# chat.txt 파일 경로
input_file_path = os.path.join(desktop_path, 'chat.txt')

# 지히 메시지만 추출하여 저장할 파일 경로
output_file_path = os.path.join(desktop_path, 'jihhi_messages.txt')

# 파일 열기
with open(input_file_path, 'r', encoding='utf-8') as infile, open(output_file_path, 'w', encoding='utf-8') as outfile:
    #outfile.write(f"지히 님과 카카오톡 대화\n")
    #outfile.write(f"저장한 날짜 : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

    for line in infile:
        # '지히'가 포함된 줄만 추출
        if '[지히]' in line:
            # 시간 및 다른 정보를 제외하고 메시지만 추출하여 저장
            message_start = line.rfind(']') + 2  # 마지막 ']' 뒤의 문자열부터 메시지 시작
            message = line[message_start:].strip()
            outfile.write(message + '\n')

print(f"지히의 메시지가 {output_file_path}에 저장되었습니다.")
