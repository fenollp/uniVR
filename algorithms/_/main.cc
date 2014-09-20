#include "_.hh"

void sep (std::ofstream& o, Faces& objs, double scale);
int center (const Face& pt, double scale);


int
main (int argc, const char* argv[])
{
    if (argc -1 != 4)
        return 1;
    auto cascade_name = argv[1];
    auto scale = std::stod(argv[2]);
    auto inFile = argv[3];
    auto outFile = argv[4];

    // ALGOS
    std::vector<std::string> algos =
        {"camshift",   "dbt",    "haar",    "haarocl",     "hog",    "surfocl"     };
    std::vector<f_init> inits =
        {camshift_init, dbt_init, haar_init, haar_ocl_init, hog_init, surf_ocl_init};
    std::vector<f_find> finds =
        {camshift_find, dbt_find, haar_find, haar_ocl_find, hog_find, surf_ocl_find};
    std::vector<f_stop> stops =
        {camshift_stop, dbt_stop, haar_stop, haar_ocl_stop, hog_stop, surf_ocl_stop};

    if (!cascade.load(cascade_name)) {
        std::cerr << "!load " << cascade_name << std::endl;
        return 2;
    }

    for (auto i = 0; i < algos.size(); ++i)
    {
        cv::VideoCapture video;
        if (!video.open(inFile)) {
            std::cerr << "!load " << inFile << std::endl;
            return 2;
        }

        bool inited = inits[i](scale, video);
        if (!inited)
            continue;

        auto tsvFile = outFile + algos[i];
        std::ofstream out(tsvFile);
        if (!out) {
            std::cerr << "!open " << tsvFile << std::endl;
            return 2;
        }

        size_t N;
        cv::Mat frame;
        Faces objects;
        for (N = 1; ; ++N) {
            video >> frame;
            if (frame.empty())
                break;

            auto s = std::chrono::high_resolution_clock::now();
            finds[i](frame, objects, scale);
            auto f = std::chrono::high_resolution_clock::now();
            auto l = std::chrono::duration_cast<std::chrono::nanoseconds>(f-s);

            out << N << '\t' << l.count() << '\t' << objects.size() << '\t';
            sep(out, objects, scale);
            out << '\n';
            objects.clear();
        }

        stops[i]();
        out.close();
        std::cout << algos[i] << ' ' << N << std::endl;
    }

    return 0;
}



void
sep (std::ofstream& o, Faces& objs, double scale) {
    if (objs.empty()) {
        o << "-1";
        return;
    }
    bool first = true;
    for (const auto& obj : objs) {
        if (first)
            first = false;
        else
            o << ',';
        o << center(obj, scale);
    }
}

int
center (const Face& pt, double scale) {
    auto x = pt.x + 0.5 * pt.width;
    auto y = pt.y + 0.5 * pt.height;
    return x * x + y * y;
}
