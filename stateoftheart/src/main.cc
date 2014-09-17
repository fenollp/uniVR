#include <opencv2/highgui/highgui.hpp>

//#include "gtest/gtest.h"
// TEST(cpp_sorter_test, null_term_str_sort)
// {
//     char arr[] = "abcdefghab";
//     char eq[]  = "aabbcdefgh";
//     int sz = sizeof(arr)/sizeof(arr[0]) - 1; // we need it, to avoid terminating \0 in "" definition case
//     array_sort(arr, sz);
//     for(int i=0; i<sz; i++)
//         EXPECT_EQ(arr[i], eq[i]);
// }
// ASSERT_NEAR(val1, val2, abs_error);
// https://code.google.com/p/googletest/wiki/AdvancedGuide

#include <iostream>
#include <fstream>

int
main (int argc, const char* argv[])
{
    if (argc -1 != 2)
        return 1;
    auto  inFile = argv[1];
    auto outFile = argv[2];

    cv::VideoCapture video;
    if (!video.open(inFile)) {
        std::cerr << "!load " << inFile << std::endl;
        return 2;
    }

    std::ofstream out(outFile);
    if (!out) {
        std::cerr << "!open " << outFile << std::endl;
        return 2;
    }

    //algo_init();

    size_t N;
    cv::Mat frame;
    for (N = 1; ; ++N)
    {
        video >> frame;
        if (frame.empty())
            break;////
        //res = algo_find(frame);
    }

    //algo_stop();

    std::cout << N << std::endl;
    out.close();

    return 0;
}
