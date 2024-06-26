use std::fs;

static INPUT_FILE: &str = "../../data/2022/day04.txt";

fn main() {
    let contents = fs::read_to_string(INPUT_FILE).expect("The file path should be valid");
    let assignment_list = AssignmentList::from_contents(&contents);

    println!("Answer to Part a: {}", solve_part_a(&assignment_list));
    println!("Answer to Part b: {}", solve_part_b(&assignment_list));
}

struct Assignment {
    lower: i32,
    upper: i32,
}

impl Assignment {
    // string is in the form "1-3", not necessarily single digits
    fn from_str(s: &str) -> Assignment {
        let mut nums = s.split('-');
        let lower = nums.next().unwrap().parse::<i32>().unwrap();
        let upper = nums.next().unwrap().parse::<i32>().unwrap();
        Assignment { lower, upper }
    }
}

struct AssignmentPair {
    assignments: (Assignment, Assignment),
}

impl AssignmentPair {
    // line is in the form "1-3,5-7" , not necessarily single digits
    fn from_line(line: &str) -> AssignmentPair {
        let mut assignments = line.split(',');
        let ass1 = assignments.next().unwrap();
        let ass2 = assignments.next().unwrap();
        AssignmentPair {
            assignments: (Assignment::from_str(ass1), Assignment::from_str(ass2)),
        }
    }

    // returns true if one assignment fully contains the other
    fn is_fully_contained(&self) -> bool {
        let (ass1, ass2) = &self.assignments;
        if ass1.lower <= ass2.lower && ass1.upper >= ass2.upper {
            return true;
        }
        if ass2.lower <= ass1.lower && ass2.upper >= ass1.upper {
            return true;
        }
        false
    }

    // returns true if there is any overlap between assignments
    fn is_overlap(&self) -> bool {
        let (ass1, ass2) = &self.assignments;
        if ass1.upper < ass2.lower || ass2.upper < ass1.lower {
            return false;
        }
        true
    }
}

struct AssignmentList {
    assignments: Vec<AssignmentPair>,
}

impl AssignmentList {
    fn from_contents(contents: &str) -> AssignmentList {
        AssignmentList {
            assignments: contents.lines().map(AssignmentPair::from_line).collect(),
        }
    }
}

fn solve_part_a(assignment_list: &AssignmentList) -> i32 {
    assignment_list
        .assignments
        .iter()
        .map(AssignmentPair::is_fully_contained)
        .map(|b| b as i32)
        .sum()
}

fn solve_part_b(assignment_list: &AssignmentList) -> i32 {
    assignment_list
        .assignments
        .iter()
        .map(AssignmentPair::is_overlap)
        .map(|b| b as i32)
        .sum()
}
