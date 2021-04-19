#!/usr/bin/env python3

import argparse
import datetime
import time

from typing import List


def main():
    args = setup_args()
    current_year = get_current_year()
    if args.week_number:
        week_number = args.week_number
    if not args.week_number:
        # print("NO week number provided")
        week_number = get_current_week_number()

    print(f"week_number:{week_number}")
    dates = get_date_range_from_week(current_year, week_number)
    print(f"dates:{dates}")

    # display_dates(dates, prefix="## ")
    weekly_template = get_template(week_number, dates)
    weekly_template += "\n"
    file_name = get_file_name(week_number, dates)
    print(weekly_template)
    print(f"File_name:{file_name}")


def get_current_week_number() -> int:
    """
    Get current week number - add 1 for the off by 1 found during development
    This is only for calculating the dates correclty
    Once we have the desired dates, we decrement week_number by 1 to match calendars
    """
    # https://www.kite.com/python/answers/how-to-get-the-week-number-from-a-date-in-python
    # http://week-number.net/programming/week-number-in-python.html
    today = datetime.date.today()
    print(f"today:{today}")
    return today.isocalendar()[1]


def get_current_year() -> int:
    now = datetime.datetime.now()
    return now.year


def get_date_range_from_week(year: int, week_number: int) -> List[datetime.datetime]:
    # http://mvsourcecode.com/python-how-to-get-date-range-from-week-number-mvsourcecode/

    print(f"{year=}|{week_number=}")

    dates = []
    first_day_of_week = datetime.datetime.strptime(
        f"{year}-W{week_number}-1", "%Y-W%W-%w"
    ).date()
    print(f"{first_day_of_week=}")

    # SET TO 5 to get ONLY work week
    for i in range(5):
        date = first_day_of_week + datetime.timedelta(days=i)
        dates.append(date)

    return dates


def display_dates(dates: list, prefix: str = "", suffix: str = ""):
    for date in dates:
        print(f"{prefix}{date}{suffix}")


def setup_args() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=None)
    parser.add_argument("-w", "--week_number", type=int, required=False)
    return parser.parse_args()


def iter_year_weeks():
    weeks = 54
    for i in range(weeks):
        start = datetime.datetime.strptime(f"2020-W{i}-1", "%Y-W%W-%w").date()
        end = datetime.datetime.strptime(f"2020-W{i}-6", "%Y-W%W-%w").date()
        print(f"{i}: {start} - {end}")


def get_template(week: int, dates: List[datetime.datetime]) -> str:
    """
    Creates weekly template of following markdown format:
    # Week ##: Monday, MONTH DD - Friday, MONTH DD, YYYY
    ## Jira Tickets
    ## TODO
    ## Monday
    ## Tuesday
    ## Wednesday
    ## Thursday
    ## Friday
    """
    template_sections = []
    # header
    header = get_header(week, dates)
    template_sections.append(header)
    # Jira Tickets
    jira_section = "## Jira Tickets"
    template_sections.append(jira_section)
    # TODO
    week_todo_section = "## Week TODO"
    template_sections.append(week_todo_section)
    # MONDAY - FRIDAY
    work_week_section = get_work_week_section(dates)
    template_sections.append(work_week_section)
    return "\n\n".join(template_sections)


def get_header(week: int, dates: List[datetime.date]) -> str:
    """
    Dates correspond to the following numbers:
    MONDAY = 0
    TUESDAY = 1
    WEDNESDAY = 2
    THURSDAY = 3
    FRIDAY = 4
    SATURDAY = 5
    """
    # account for weeks between 2 years
    if dates[0].year == dates[4].year:
        start = dates[0].strftime("%A, %B %d")
    else:
        start = dates[0].strftime("%A, %B %d, %Y")
    end = dates[4].strftime("%A, %B %d, %Y")
    header = f"# Week {week}: {start} - {end}"
    return header


def get_work_week_section(dates: List[datetime.date]) -> str:

    work_week_section = []
    for date in dates:
        day_section = []
        section_header = f"## {date.strftime('%A, %B %d, %Y')}"
        day_section.append(section_header)

        day_section_areas = [
            "Agenda",
            "To Do",
            "Accomplished",
            "Escalations",
            "Meetings",
        ]

        for section_area in day_section_areas:
            day_section.append(f"***{section_area}***")

        work_week_section.append("\n\n".join(day_section))

    # End of work week section
    end_of_work_week = ["Lesson of the week", "Ideas for team improvement"]
    for section in end_of_work_week:
        work_week_section.append(f"***{section}***")

    return "\n\n".join(work_week_section)


def get_file_name(week_number: int, dates: List[datetime.datetime]) -> str:
    """
    File name follows the format:
    w##-MM-DD-MM-DD.md

    Implemented as a list that is joined at the end for legibility purposes
    """
    file_name = [f"w{week_number}"]
    # start date
    file_name.append(f"{dates[0].strftime('%m-%d')}")
    # end date
    file_name.append(f"{dates[-1].strftime('%m-%d')}")
    # original
    # file_name = f"w{week_number}-{dates[0].strftime('%m-%d')}-{dates[-1].strftime('%m-%d')}.md"

    return "-".join(file_name) + ".md"


if __name__ == "__main__":
    main()
