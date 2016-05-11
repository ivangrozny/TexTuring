
public class SimuParam
{
  // simulation itterations
  public int      iterations = 10000; 

  // render texture width/height
  public int      Width = 0;
  public int      Height = 0;

  // reaction diffusion parameters
  public float minU = 0.096f;
  public float maxU = 0.101f;
  public float minV = 0.035f;
  public float maxV = 0.04f;
  public float minFeed = 0.032f;
  public float maxFeed = 0.037f;
  public float minKill = 0.0535f;
  public float maxKill = 0.0595f;

  public float Tech = 1f;
  public int mode = 0;

  public JSONObject serialize()
  {
    JSONObject json = new JSONObject();

    json.setInt("iterations", iterations);
    json.setInt("width", Width);
    json.setInt("height", Height);

    json.setFloat("minU", minU);
    json.setFloat("maxU", maxU);
    json.setFloat("minV", minV);
    json.setFloat("maxV", maxV);
    json.setFloat("minFeed", minFeed);
    json.setFloat("maxFeed", maxFeed);
    json.setFloat("minKill", minKill);
    json.setFloat("maxKill", maxKill);

    json.setInt("mode", mode);
    json.setFloat("Tech", Tech);

    return json;
  }
  public void deserialize(JSONObject json)
  {
    iterations = json.getInt("iterations", iterations);
    Width = json.getInt("width", Width);
    Height = json.getInt("height", Height);

    minU = json.getFloat("minU", minU);
    maxU = json.getFloat("maxU", maxU);
    minV = json.getFloat("minV", minV);
    maxV = json.getFloat("maxV", maxV);
    minFeed = json.getFloat("minFeed", minFeed);
    maxFeed = json.getFloat("maxFeed", maxFeed);
    minKill = json.getFloat("minKill", minKill);
    maxKill = json.getFloat("maxKill", maxKill);

    mode = json.getInt("mode", mode);
    Tech = json.getFloat("Tech", Tech);
  }
}
public class JobParam
{
  public String pathInput = "C:/2014/react.png";
  public String pathOutput= "C:/2014/diffu.png";

  public SimuParam simu = new SimuParam ();

  public JSONObject serialize()
  {
    JSONObject json = new JSONObject();
    json.setString("pathInput", pathInput);
    json.setString("pathOutput", pathOutput);
    json.setJSONObject("simu", simu.serialize());
    return json;
  }

  public void deserialize(JSONObject json)
  {
    json.getString("pathInput", pathInput);
    json.getString("pathOutput", pathOutput);
    simu.deserialize(json.getJSONObject("simu"));
  }
}


public class GpuController
{
  String gpuAppPath_win = "gpu" + File.separator + "ReactDiffGpu.exe";
  String gpuAppPath_mac = "gpu" + File.separator + "ReactDiffGpu.exe";
  String gpuAppPath_linux = "gpu" + File.separator + "ReactDiffGpu.exe";
  String paramSwapFile = "gpu"+File.separator+"job.json";

  boolean isAppLaunched = false;
  boolean isAppConnected = false;

  JobParam job = new JobParam();

  String getAppPath()
  {
   if(platform == MACOSX) {
      return gpuAppPath_mac;
    }
    else if(platform == WINDOWS) {
      return gpuAppPath_win;
    }
    else if(platform == LINUX) {
      return gpuAppPath_win;
    }
    return gpuAppPath_win;
  }
  
  /*void launchApp(String _args)
  {
    String pwd = sketchPath("");
    println("pwd : "+pwd);
    String[] args = { pwd + File.separator + getAppPath(), _args };
    launch(args);
    println("application gpu started " + _args);
  }*/
  
  void launchApp(String _args, int w, int h)
  {
    String pwd = sketchPath("");
    println("external app :" + pwd + getAppPath());
    String[] args = { pwd + File.separator + getAppPath(),
                      _args,
                      str(w),
                      str(h)};
    launch(args);
    println("application gpu started " + _args);
  }
  
  public void saveJob(String path)
  {
    String[] lines = new String[1];
    lines[0] = job.serialize().toString();
    String p = "gpu"+File.separator+path;
    saveStrings(path, lines);
  }

  public void launchSimu()
  {
    String pwd = sketchPath("");
    saveJob(paramSwapFile);
    launchApp(pwd + paramSwapFile, width, height);
  }
  
  public void launchSimu(JobParam j, int w, int h)
  {
    job = j;
    String pwd = sketchPath("");
    saveJob(paramSwapFile);
    launchApp(pwd + paramSwapFile, width, height);
  }
}

//interface with the rest of the application
PImage renderGpu(PImage imageIn, int widthOut ){
  PImage image = imageIn.get();
  int imgWidth = int( params.o[2]*image.width/100 ); if (imgWidth<5) imgWidth = 5;

  image.resize(imgWidth, 0 );

  image = renderGpu(image);
  
  //image.resize( widthOut, 0 );  // may be faster but uglyer (blobs not perfectly round)
  BufferedImage scaledImg = Scalr.resize( (BufferedImage)image.getNative(), Scalr.Method.QUALITY, Scalr.Mode.FIT_TO_WIDTH, widthOut);  // load PImage to bufferImage 
  image = new PImage(scaledImg);

  if (threshold) image.filter(THRESHOLD, map(params.o[1],0,255,0,1) );

  return image ;
}
public PImage renderGpu(PImage imageInput)
{
  float[] mini = { 0.00, 0.01, 0.03, 0.005 };  // F, K, diffU, diffV
  float[] maxi = { 0.15, 0.08, 0.11, 0.05 };  // F, K, diffU, diffV

  String pathIn = sketchPath("")  + "gpu" + File.separator + "input.png";
  String pathOut = sketchPath("") + "gpu" + File.separator + "output.png";
  saveImage(imageInput, pathIn); 
  
  //compute ratio
  float ratio = imageInput.width / (float)imageInput.height;
  int h = imageInput.height;
  int w = (int)(h * ratio);

  JobParam job = new JobParam();
  job.pathInput = pathIn;
  job.pathOutput = pathOut;
  job.simu.iterations = params.o[0];
  job.simu.mode = params.iniState;
  job.simu.Width = 0;
  job.simu.Height = 0;
  job.simu.minFeed = map(params.b[0], 0, 200, mini[0], maxi[0]);
  job.simu.maxFeed = map(params.w[0], 0, 200, mini[0], maxi[0]);
  job.simu.minKill = map(params.b[1], 0, 200, mini[1], maxi[1]);
  job.simu.maxKill = map(params.w[1], 0, 200, mini[1], maxi[1]);
  job.simu.minU = map(params.b[2], 0, 200, mini[2], maxi[2]);
  job.simu.maxU = map(params.w[2], 0, 200, mini[2], maxi[2]);
  job.simu.minV = map(params.b[3], 0, 200, mini[3], maxi[3]);
  job.simu.maxV = map(params.w[3], 0, 200, mini[3], maxi[3]);
  GpuController gpu = new GpuController();
  gpu.launchSimu(job, w , h);
  
  return pollGpuFinish(pathOut);
}

public PImage pollGpuFinish(String path)
{
  File f = new File(dataPath(path));
  if (f.exists()) {
   f.delete(); 
  }
  PImage img = null;
  int count = 0;
 
  println("begin polling");
  do {
    f = new File(dataPath(path));
    delay(500);
  } while (!f.exists() && count++ < 10000);
  println("end polling");
  img = loadImage(path);

  return img;
}